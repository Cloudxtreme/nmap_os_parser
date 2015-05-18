#!/bin/bash
#nmap_os_parser.sh v1.0
#Author: 	hecky
#Web: 		Neobits.org
#Twitter: 	@hecky

args=$#
dir=$1
outfile=$2

function args_validate(){
	#Check number of arguments
	if [ $args -ne 2 ];then
		echo -e "\n\e[1;31m./nmap_os_parser.sh:\e[m\tMake a xls file of (IP,DNS,OS details) from all nmap's files\n"
	echo -e "\t\e[1;33m./nmap_os_parser <path> <outfile.xls>\e[m"
	echo -e "\n\n\t<<< \e[36m@hecky\e[m from \e[36mNeobits.org\e[m >>>"
		exit
	fi

	#Check if outfile has the correct extension otherwise...set it
	if ! [[ $outfile =~ ".xls"$ ]];then
		outfile=$(echo -n $outfile".xls")
	fi

	#Check if path exists
	if [[ ! -d $dir ]];then
		echo -e "\e[1;31m[-]\e[m Incorrect Path"
		exit
	else
		dir=$(echo -n $dir"/"|tr -s "/")
	fi

	#Check if there are nmap files at give path
	nmap_dir=$dir"*.nmap"
	nmap_files=$(ls $nmap_dir &> /dev/null && echo "si" || echo "no")
	if [[ $nmap_files == "no" ]];then
		echo -e "\e[1;31m[-]\e[m Here are not nmap files (Douh!)"
		exit
	fi
}
args_validate

function parse_data(){
	echo -e "\e[1;33m[+]\e[m Working..."
	echo -e "IP\tDNS\tTipo de Dispositivo\tSistema\tDetalles del SO" > $outfile
	for i in $(ls -1 $dir*.nmap);do
		host=$(cat "$i" | grep "Nmap scan report.*" )
		ip=$(echo "$host" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}""\)*$"| tr -d ")")
		dns=$( echo $host |grep "Nmap scan report for.*(" -o | sed 's/\s($//;s/Nmap\sscan\sreport\sfor\s//')
		if_dns=$(echo $dns | grep -qo "[a-Z0-9].*";echo -n $?)
		if [[ $if_dns == "1" ]];then
			dns=$(echo "N/A" )
		fi
		echo -en "$ip\t$dns\t" >> $outfile
		cat $i | grep -e "^Device type.*" -e "^OS details.*" -e "^Running.*" | sed "s/Device\stype:\s//g;s/Running\s(JUST\sGUESSING):\s/Probablemente: /g;s/Running:\s//g;s/OS\sdetails:\s//g;s/general\spurpose/PC|Servidor/g;s/\s/@/g" | tr "\n" "\t" | sed "s/@/ /g;s/\t$/@/;s/switch/Switch/" | tr -d "@" >> $outfile
		echo "" >> $outfile
	done
	echo -e "\e[1;33m[+]\e[m Data saved at \e[31m$outfile\e[m"
	echo -e "\n\n\t<<< \e[36m@hecky\e[m from \e[36mNeobits.org\e[m >>>"
}
parse_data
