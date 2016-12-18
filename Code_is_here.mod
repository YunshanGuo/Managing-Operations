param numPlanttype; 
param numSettype;
param numUnittype;
# let i correspond as follows
# set: 1 (SM-Steel metal), 2 (SI-Steel insert), 3 (GM-Graphite Metal), 4 (GI-Graphite Insert)
# unit: 1 (SS-steel shaft), 2 (GS-graphite shaft), 3 (FIH-Forged Iron Heads), 4 (MH-Metal wood head), 5 (IH-Titanium insert heads)
# let j correspond as follows
# 1 (C-chandler), 2 (G-Glendale), 3 (T-Tuscon)

param set_timecapacity {j in 1 .. numPlanttype};
param unit_timecapacity {j in 1 .. numPlanttype};
param unit_packagingtime {j in 1 .. numPlanttype};
param set_minDemand {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param set_maxDemand {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param set_MPA_cost {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param set_revenue {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param set_assemblytime {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param set_advertisingfee {i in 1 .. numSettype, j in 1 .. numPlanttype }; 
param unit_minDemand {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param unit_maxDemand {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param part_MPA_cost {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param part_revenue {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param part_assemblytime {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param part_packingtime {i in 1 .. numUnittype, j in 1 .. numPlanttype }; 
param part_advertisingfee {i in 1 .. numUnittype, j in 1 .. numPlanttype };
param labor_settime {i in 1 .. numSettype, j in 1 .. numPlanttype };  

var x {i in 1 .. numSettype, j in 1 .. numPlanttype } >= 0; # amount of set produced of type i in plant j in month 1
var y {i in 1 .. numSettype, j in 1 .. numPlanttype } >= 0; # amount of set produced of type i in plant j in month 2
var z {i in 1 .. numSettype, j in 1 .. numPlanttype } >= 0; # amount of set demanded of type i in plant j in month 1
var J {i in 1 .. numSettype, j in 1 .. numPlanttype } >= 0; # amount of set demanded of type i in plant j in month 2
var a {i in 1 .. numUnittype, j in 1 .. numPlanttype } >= 0; # amount of unit produced of type i in plant j in month 1
var b {i in 1 .. numUnittype, j in 1 .. numPlanttype } >= 0; # amount of unit produced of type i in plant j in month 2
var c {i in 1 .. numUnittype, j in 1 .. numPlanttype } >= 0; # amount of unit demanded of type i in plant j in month 1
var d {i in 1 .. numUnittype, j in 1 .. numPlanttype } >= 0; # amount of unit demanded of type i in plant j in month 2
var MPA >= 0;

maximize totalProfit:
	(sum{i in 1 .. numUnittype, j in 1 .. numPlanttype} (
	#consider this revenue
	part_revenue[ i, j ] * c[i, j] + part_revenue[ i, j ] * d[i, j] - 
	(0.08 * (part_MPA_cost[ i, j ] * (2*a[i, j] +b[i, j ] - 2*c[i, j] -d[i, j]))) -
	(part_MPA_cost[i, j] * a[i, j] + 1.12* part_MPA_cost[ i, j] * b[ i, j])
	)) 
	+
	(sum{w in 1 .. numSettype, j in 1 .. numPlanttype} (
	set_revenue[w, j] * z[w, j] + set_revenue[w, j] * J[w, j] -
	#consider this storage cost
 	0.08 * (set_MPA_cost[w, j] * (2* x[w, j] + y[w, j] - 2* z[w, j] - J[w, j])) -
 	#consider this MPA
 	(set_MPA_cost[w, j] *x[w, j] + 1.12* set_MPA_cost[w, j]* y[w, j])
	));	
subject to SETassemblytime_m1 {j in 1 .. numPlanttype}: 
	(sum{ i in 1 .. numSettype} (set_assemblytime[i, j] * x[ i, j])) <= set_timecapacity[j];
subject to PARTSassemblytime_m1 {j in 1 .. numPlanttype}:
	(sum{i in 1 .. numUnittype} (part_assemblytime[i, j] * a[ i, j])) + (sum{i in 1 .. numSettype} (labor_settime[i, j] * x[ i, j])) <= unit_timecapacity[j];
subject to PARTSpackingtime_m1 {j in 1 .. numPlanttype}:
	(sum{i in 1 .. numUnittype} (part_packingtime[i, j] * a[ i, j])) <= unit_packagingtime[j];
subject to SETassemblytime_m2 {j in 1 .. numPlanttype}: 
	(sum{ i in 1 .. numSettype} (set_assemblytime[i, j] * y[ i, j])) <= set_timecapacity[j];
subject to PARTSassemblytime_m2 {j in 1 .. numPlanttype}:
	(sum{i in 1 .. numUnittype} (part_assemblytime[i, j] * b[ i, j])) + (sum{i in 1 .. numSettype} (labor_settime[i, j] * y[ i, j])) <= unit_timecapacity[j];
subject to PARTSpackingtime_m2 {j in 1 .. numPlanttype}:
	(sum{i in 1 .. numUnittype} (part_packingtime[i, j] * b[ i, j])) <= unit_packagingtime[j];
#advertising
subject to advertising_m1:
	(sum{i in 1 .. numUnittype, j in 1 .. numPlanttype} (part_advertisingfee[i, j]*a[i, j])) + (sum{i in 1 .. numSettype, j in 1 .. numPlanttype} (set_advertisingfee[i, j]*x[i, j])) <= 20000;
subject to advertising_m2:
	(sum{i in 1 .. numUnittype, j in 1 .. numPlanttype} (part_advertisingfee[i, j]*b[i, j])) + (sum{i in 1 .. numSettype, j in 1 .. numPlanttype} (set_advertisingfee[i, j]*y[i, j])) <= 20000;
#graphite
subject to graphite_m1:
	sum{j in 1 .. numPlanttype} 4*(13 *x[3,j] + 13 * x[4, j] + a[2, j]) <= 16000;
subject to graphite_m2:
	sum{j in 1 .. numPlanttype} 4*(13 *y[3,j] + 13 * y[4, j] + b[2, j]) <= 16000;

	
subject to minsetdemand_m1 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
	set_minDemand[i, j] <= z[i, j] ;
subject to maxsetdemand_m1 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
    z[i, j] <= set_maxDemand[i, j];
subject to minsetdemand_m2 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
	set_minDemand[i, j] <= J[i, j] ;
subject to maxsetdemand_m2 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
    J[i, j] <= set_maxDemand[i, j];
subject to minsetsupply_m1 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
	x[i, j] - z[i, j] >= 0;
subject to maxsetsupply_m1 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
    x[i, j] <= set_maxDemand[i, j];
subject to minsetsupply_m2 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
	y[i, j] +x[i, j] - z[i, j] -J[i, j] >= 0 ;
subject to maxsetsupply_m2 {i in 1 .. numSettype, j in 1 .. numPlanttype}:
    y[i, j] +x[i, j] - z[i, j] <= set_maxDemand[i, j];
#unitdemand&suppl
subject to minunitdemand_m1 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
	#constraint for demand
	c[i, j] >= unit_minDemand[i, j];
subject to maxunitdemand_m1 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
	c[i, j] <= unit_maxDemand[i, j];
subject to minunitdemand_m2 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
	d[i,j]>= unit_minDemand[i, j] ;
subject to maxunitdemand_m2 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
    d[i, j] <= unit_maxDemand[i, j];
	#constraint for supply
	#month 1
subject to minunitsupply_m1 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
	a[i, j] - c[i, j] >= 0;
subject to maxunitsupply_m1 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
    a[i, j] <= unit_maxDemand[i, j];
subject to minunitsupply_m2 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
	#month 2
	b[i, j] + a[i, j] - c[i, j] - d[i, j] >= 0;
subject to maxunitsupply_m2 {i in 1 .. numUnittype, j in 1 .. numPlanttype}:
    b[i, j] + a[i, j] - c[i, j] <= unit_maxDemand[i, j];
subject to MPA_total_cost:
	MPA = ((sum{i in 1 .. numUnittype, j in 1 .. numPlanttype} (
	(part_MPA_cost[i, j] * a[i, j] + 1.12* part_MPA_cost[ i, j] * b[ i, j])
	)) +
	(sum{w in 1 .. numSettype, j in 1 .. numPlanttype} (
 	0.08 * (set_MPA_cost[w, j] * (2* x[w, j] + y[w, j] - 2* z[w, j] - J[w, j])) +
 	#consider this MPA
 	(set_MPA_cost[w, j] *x[w, j] + 1.12* set_MPA_cost[w, j]* y[w, j])
	)));	

