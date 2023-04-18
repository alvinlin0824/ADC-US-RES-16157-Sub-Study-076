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
proc means data = esa median noprint;
class filename;
where eTime between 36000 and 432000;
var s_immediate;
output out = esa_median(drop = _TYPE_ _FREQ_) median = s_median N = n;
run;

/*Left Join esa with esa_median to get interpolate data*/
data esa_interpolate;
merge esa(in = x) esa_median(in = y);
by filename;
if x;
s_norm = s_immediate/s_median;
if eTime <= 28800 and s_norm ^= .;
eTime = eTime/3600;
run;

/*Trapezoidal numerical integration*/
proc iml;
/**Given two vectors x,y where y=f(x), this module
   approximates the definite integral int_a^b f(x) dx 
   by the trapezoid rule. 
   The vector x is assumed to be in numerically increasing
   order so that a=x[1] and b=x[nrow(x)].
   The module does not assume equally spaced intervals.
   The formula is 
   Integral = Sum(  (x[i+1] - x[i]) * (y[i] + y[i+1])/2 )   
**/
start TrapIntegral(x,y);
   N = nrow(x);
   dx    =   x[2:N] - x[1:N-1];
   meanY = ( y[2:N] + y[1:N-1] )/2;
   return( dx` * meanY );
finish;
 
/** test it **/
x = {

3.6555555537,
4.735833331,
5.9905555537
};
y = {
0.9944829673-1,
0.8883687903-1,
0.9346220902-1
};
area = TrapIntegral(x,y);
print area;


