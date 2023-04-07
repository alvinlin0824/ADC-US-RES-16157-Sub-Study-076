/*UUU \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\CDM\RX Data\Sub-Study 076*/

/*NEAT \\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_Statistics\Statistics\NEAT*/

/*Import Upload Data and filter csv*/

libname out "\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\Clinical Study Files\Sensor Systems\ADC-US-RES-16157_InHouse Sensor\Statistics\Programs\SE076\AL\Data";
filename dir pipe "dir /b/l/s  ""\\oneabbott.com\dept\ADC\Technical_OPS\Clinical_Affairs\CDM_Statistics\Statistics\NEAT\NEAT3100_Algo0491_201017_alldata\NEATToCSV\*.csv""";

/*All list with extension csv*/
data list;
	infile dir truncover;
	input path $256.;
	subject = substr(path,131,4);
	condition_id = upcase(substr(path,142,3));
	date_time = compress(substr(path,146,13));
run;

/*Loop Data*/
data esa;
    length filename $100.;
	set list;
	infile dummy filevar = path length = reclen end = done missover dlm='2C'x dsd firstobs=2;
	do while(not done);
		filename = substr(path,131,30);
		input eTime BG instrumentType $ s_immediate;
		output;
	end;
run;

data out.esa;
set esa;
if find(filename,".c") then filename = tranwrd(filename,".c","");
run;


