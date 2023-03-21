/*UUU \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\CDM\RX Data\Sub-Study 076*/

/*NEAT \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_Statistics\Statistics\NEAT*/

/*Import Upload Data and filter csv*/
filename dir pipe "dir /b/l/s  ""\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\CDM\RX Data\Sub-Study 076\*.csv""";

/*All list with extension csv*/
data mlist;
 infile dir truncover;
 input fullname $256.;
run;

data mlist_auu;
 length filename $50.;
 set mlist;
 if find(fullname,"gluc.csv") and ^find(fullname,"BGM","i");
 filename=scan(fullname,-1,'\'); 
 loc=substr(fullname,1,find(fullname,'\', -length(fullname))); 
 subj=input(substr(filename,8,4),best.); condi=upcase(substr(filename,19,3)); tmstamp=substr(filename,23,13);
run;

data mlist_auu1;
 set mlist_auu;
 nf = _n_;
 call symputx("last_nf",nf);
run;

%macro loop; *loop through files to import them into SAS and stacking;

%do j=1 %to &last_nf; *&last_nf;

data mlist_null;
 set mlist_auu1;
 where nf=&j;
 call symputx("auufile",substr(filename,1,length(filename)-13));
 call symputx("loc",loc); call symputx("subj",subj); call symputx("condi",condi); call symputx("seq",seq);
run;

data gluc_&j;
 infile "&loc.\&auufile._gluc.csv" lrecl=32767 encoding="WLATIN1" dlm='2C'x missover dsd firstobs=3;
 input uid: $char16. date: yymmdd10. time: time8. type: $char56. gl: best8. st: best8. tr: best1. nonact: best1.;
run;

%end;
%mend loop;

%loop;

data comb_gluc;
 set gluc_1-gluc_&last_nf;
 format dtm datetime16. event sensor $25.;
 recid=uid; hour=hour(time); min=minute(time); sec=second(time); dtm=dhms(date, hour, min, sec); 
 loc=substr(condition_id,1,2); *sensor_num=1; sensor=strip(subjid)||'_'||strip(condition_id)||'_'||strip(sensor_num);
 if type='906' then event='Current Glucose'; else if type='905' then event='Historic Glucose'; else if type='904' then event='Real-time Glucose';
 drop hour min sec uid;
run;









/*data gluc_list events_list freestyle_list;*/
/* set list;*/
/* /*Gluc.csv #736*/*/
/* if find(filepath,"gluc.csv") and ^find(filepath,"BGM","i") then output gluc_list;*/
/* /*Events.csv #736*/*/
/* if find(filepath,"events.csv") and ^find(filepath,"BGM","i") then output events_list;*/
/* /*freestyle.csv #182                             /*ignore case*/*/
/* if find(filepath,"freestyle.csv") and find(filepath,"BGM","i") then output freestyle_list;*/
/*run;*/