#!/bin/sh 

sinaurl="http://hq.sinajs.cn/list=" 
context=$(dirname $0)
short_scret=$1
codes=$context"/codes"
refreshGap=1s


# curl one stock from sina, save cache in $result
getStock()
{
 target=${sinaurl}""$1
 result=$result$'\n'`curl ${target} 2>/dev/null | iconv -f gb2312 -t utf-8 | sed "s/var //" | sed "s/ /_/g"`
}

# for each code in $codes, -> getStock
readStock()
{
 if [ -z $short_scret ]; then
  result=`echo 'title="--name--,open,old,cur,top,bottom,gapv\%"'`
 else
  result=
 fi
 while read myline
 do
  getStock $myline
 done < $codes
}

# show stock info on terminal
printStock()
{
 clear
 if [ -z $short_scret ]; then
  for r in $result
  do
   echo $r | awk '{
	len=split(substr($r,index($r,"=")+2,100),arr,",");
		name=substr(arr[1],0,16)
		open=substr(arr[2],0,7)
	if(open=="0.00"){ #check if is suspended
		open="---"
		old="---"
		cur="---"
		gap="---"
		gapv="delta"
	} else {
		old=substr(arr[3],0,7)
		cur=substr(arr[4],0,7)
		top=substr(arr[5],0,7)
		bottom=substr(arr[6],0,7)
		if(old=="old"){
			gap="%"
		} else {
			gap=substr((cur-old)/old*100,0,7)
		}
		if(old=="old"){
			gapv="delta"
		} else {
			gapv = cur-old
		}
		
	}
	if (gap>0) {
		printf("\033[31m%s\033[0m  \t",name)
	} else {
		printf("\033[32m%s\033[0m  \t",name)
	}
	# printf("%s  \t",name)
	# printf("\033[36m%s\033[0m\t",open)
	# printf("%s\t",old)

	if (gap>0) {
		printf("\033[31m%s\033[0m\t",cur)
	} else {
		printf("\033[32m%s\033[0m\t",cur)
	}

	if (gap>=0) {
		printf("\033[31m%s\033[0m\t",gap)
	} else if(gap!="-nan"){
		printf("\033[32m%s\033[0m\t",gap)
	}

	if (gap>=0) {
		printf("\033[31m%s\033[0m\t",gapv)
	} else if(gap!="-nan"){
		printf("\033[32m%s\033[0m\t",gapv)
	}

	print"\n"
   }'
  done
 else
  for r in $result
  do
   echo $r | awk '{
	len=split(substr($r,index($r,"=")+2,100),arr,",");
		open=substr(arr[2],0,7)
	if(open=="0.00"){ #check if is suspended
		cur="---"
		gap="---"
	} else {
		old=substr(arr[3],0,7)
		cur=substr(arr[4],0,7)
		gap=substr((cur-old)/old*100,0,7)
	}

	if (gap>0) {
		printf("\033[31m%s\033[0m\t",cur)
	} else {
		printf("\033[32m%s\033[0m\t",cur)
	}

	if (gap>=0) {
		printf("\033[31m%s\033[0m\t",gap)
	} else if(gap!="-nan"){
		printf("\033[32m%s\033[0m\t",gap)
	}

	print"\n"
   }'
  done
 fi
}

# main entrance, execute every 5s
main()
{
  while (true)
  do
   readStock
   printStock
   sleep $refreshGap
  done
}

# main entrance
main
