/*UUU \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\CDM\RX Data\Sub-Study 076*/

/*NEAT \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_Statistics\Statistics\NEAT*/


libname out "\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\Statistics\Programs\SE076\AL\Data";
/*Filter csv only*/
filename dir pipe "dir /b/l/s  ""\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_Statistics\Statistics\NEAT\NEAT3100_Algo0491_201017_alldata\NEATToCSV\*.csv""";

/*All list with extension csv*/
/*data list;*/
/*	infile dir truncover;*/
/*	input path $256.;*/
/*run;*/

/*Loop Data*/
/*data esa;*/
/*    length filename $100.;*/
/*	set list;*/
/*	infile dummy filevar = path length = reclen end = done missover dlm='2C'x dsd firstobs=2;*/
/*	do while(not done);*/
/*		filename = substr(path,131,30);*/
/*	    subject = substr(path,131,4);*/
/*	    condition_id = upcase(substr(path,142,3));*/
/*	    date_time = compress(substr(path,146,13));*/
/*		input eTime BG instrumentType $ s_immediate;*/
/*		output;*/
/*	end;*/
/*run;*/

/*Remove filename with .c and write data to T-drive*/
/*data out.esa;*/
/*set esa;*/
/*if find(filename,".c") then filename = tranwrd(filename,".c","");*/
/*run;*/

/*Import Data*/
data esa;
	set out.esa (drop = BG instrumentType);
run;

/*Get median based on eTime between 10 hours and 120 hours*/
proc means data = esa median noprint nway;
class filename;
where eTime between 36000 and 432000;
var s_immediate;
output out = esa_median(drop = _TYPE_ _FREQ_) median = s_median N = n;
run;

/*Left Join esa with esa_median to get interpolate data*/
data esa_snorm;
merge esa(in = x) esa_median(in = y);
by filename;
if x;
s_norm = s_immediate/s_median;
/*Filter first 8 hours */
if eTime <= 28800 and s_norm ^= .;
eTime = eTime/3600;
run;

/*Trapezoidal numerical integration*/

data esa_area;
set esa_snorm;
by filename;
lag_eTime = lag(eTime);
lag_s_norm = lag(s_norm);
if first.filename then do; 
lag_eTime = 0;
lag_s_norm = 0;
end;
/*Calculate the trapzoid area*/
if first.filename then area = 0;
else area + (eTime - lag_eTime) * (s_norm + lag_s_norm - 2) / 2;
if last.filename;
/*Only sum up the area when s_normlnterp < 1*/
where s_norm < 1;
keep filename area;
run;


/*Left Join to get complete data*/
data esa_index;
retain filename s_median n area category;
format category $10.;
merge esa_median(in = x) esa_area(in = y);
by filename;
if x;
/*Assign ESA Classification*/
if area = . then category = "NaN";
else if  -1 < area <= 0 then category = "None";
else if -2 < area <= -1 then category = "Minor";
else if -3 < area < -2 then category = "Moderate";
else if area <= -3 then category = "Severe";
run;