/*filename dir pipe "dir /b/l/s  ""\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\CDM\RX Data\Sub-Study 076\*.csv""";*/
filename dir pipe "dir /b/l/s  ""\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_16157\111\UUU\*.csv""";
/*All list with extension csv*/
data list;
	infile dir truncover;
	input path $256.;
/*	Extract Subject ID*/
	if find(path,"ApolADC","i") then subject = substr(path,find(path,"ApolADC","i")+7,4);
	if find(path,"AtnaADC","i") then subject = substr(path,find(path,"AtnaADC","i")+7,4);
	if find(path,"MobiADC","i") then subject = substr(path,find(path,"MobiADC","i")+7,4);
/*	Extract Condition ID*/
	if find(path,"ApolADC","i") then condition_id = upcase(substr(path,find(path,"ApolADC","i")+18,3));
	if find(path,"AtnaADC","i") then condition_id = upcase(substr(path,find(path,"AtnaADC","i")+18,3));
	if find(path,"MobiADC","i") then condition_id = upcase(substr(path,find(path,"MobiADC","i")+18,3));
run;

data events_list gluc_list freestyle_list;
	set list;
	if find(path,"events.csv","i") and ^find(path,"BGM","i") then output events_list;
    if find(path,"gluc.csv","i") or find(path,"glucPlus.csv") and ^find(path,"BGM","i") then output gluc_list;
	if find(path,"freestyle.csv","i") then output freestyle_list;
run;

/*Loop events.csv Data*/
data events;
	set events_list;
	infile dummy filevar = path length = reclen end = done missover dlm='2C'x dsd firstobs=4;
	do while(not done);
		input uid: $char256. date: yymmdd10. time:time8. type: $char56. col_4: $char3. col_5: $char11. col_6: $char4. col_7: best8. col_8: $char9. 
 snr: $char11.;
        format date date9. time time8.;
		drop uid col_4-col_8;
        output;
	end;
run;

/*Multiple Sensor Start*/
proc sort data = events;
by subject condition_id date time;
run;
data events_start;
	set events (where = (type ="SENSOR_STARTED (58)"));
	by subject condition_id;
    if last.condition_id;
run;

/*Loop gluc.csv Data*/
data gluc;
	set gluc_list;
	infile dummy filevar = path length = reclen end = done missover dlm='2C'x dsd firstobs=4;
	do while(not done);
		input uid: $char16. date: yymmdd10. time: time8. type: $char56. gl: best8. st: best8. tr: best1. nonact: best1.;
        format date date9. time time8.;
		drop uid st--nonact;
        output;
	end;
run;
/*stack*/
data auu;
	set events_start gluc;
run;
/*Remove Duplicated uploads*/
proc sort data = auu NODUP; 
by subject condition_id date time;
run;