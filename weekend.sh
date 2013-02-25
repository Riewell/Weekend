#!/bin/bash
#
#  Вычисление выходных и рабочих дней при графике работы 2/2
#  (Отсчёт ведётся с 1 февраля 2013 г. - выходной день)
#  Version 1.2
#
#  Copyright 2013 Konstantin Zyryanov <post.herzog@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#  
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  


#Функция вывода краткого списка возможных параметров
usage() {
echo "Использование: ";
echo "$0 [ [-d|--date [ДАТА]] | [-c|--calendar [МЕСЯЦ]] ] [-h|--help]";
echo;
exit;
}

#Функция вывода краткой справки
help() {
echo;
echo "Использование: ";
echo "$0 [ [-d|--date [ДАТА]] | [-c|--calendar [МЕСЯЦ]] ] [-h|--help]";
echo;
echo "  -d|--date [ДАТА]		Вывод результата на определённую пользователем";
echo "				ДАТУ, заданную в формате ДД.ММ.ГГ.";
echo "				При указании параметра с неполной датой или";
echo "				без даты - подставляется текущее значение";
echo "				из календаря системы.";
echo;
echo "  -c|--calendar [МЕСЯЦ]		Вывод результата в виде календаря";
echo "				на определённый пользователем МЕСЯЦ,";
echo "				заданный в формате ММ или ММ.ГГ.";
echo "				Если не указаны определённый месяц или год -";
echo "				подставляется текущее значение";
echo "				из календаря системы.";
echo;
echo "  -h|--help			Показать эту справку и выйти.";
echo;
exit;
}

#функция просчёта и вывода результата для одиночной даты
single_date () {
data=$1;
#Запрос даты, если она не была задана при вызове программы
if [ "$data" = "nodata" ]; then
	echo -n "Введите дату [ДД.ММ.ГГ]: ";
	read param;
	if [ "${#param}" -eq 8 ]; then
		day="${param:0:2}";
		month="${param:3:2}";
		year="${param:6:2}";
	elif [ "${#param}" -eq 5 ]; then
		day="${param:0:2}";
		month="${param:3:2}";
	elif [ "${#param}" -eq 2 ]; then
		day=$param;
	else
		echo;
		echo "Не указано что-либо определённое - будет выведен результат для текущей даты";
	fi;
	data=`date --date="$year-$month-$day" +%s`;
fi;
#Вычисление перебором от 1 февраля 2013 г. по суткам
difference=$(($data-1359655200));
difference=$(($difference/86400+1));
result="р";
for (( i=0; $i<$difference; i=$i+2 )); do
	if [ "$result" = "в" ]; then result="р"; continue; fi;
	if [ "$result" = "р" ]; then result="в"; continue; fi;
done;
#Вывод результата
echo;
date --date="@$data" "+%d %B %Y %n%A%n";
case $result in
	( "в" )
		echo "Выходной";;
	( "р" )
		echo "Рабочий";;
esac;
echo;
exit;
}

#Функция просчёта и вывода графика для заданного месяца в виде календаря
calendar() {
data=$1;
month_begin_with=`date --date="@$data" +%u`;
#Вычисление количества дней в заданном месяце
case `date --date="@$data" +%m` in
	( 01 | 03 | 05 | 07 | 08 | 10 | 12 )
		month_last_day=31;;
	( 04 | 06 | 09 | 11 )
		month_last_day=30;;
	( 02 )
		if [ $((`date --date="@$data" +%Y`%4)) != 0 ]; then
			month_last_day=28;
		else
			month_last_day=29;
		fi;;
esac;
echo;
echo "`date --date=\"@$data\" \"+%B %Y%n\"`:";
echo -e "\nПН\tВТ\tСР\tЧТ\tПТ\tСБ\tВС\n";
#Циклическое вычисление перебором от 1 февраля 2013 г. по суткам
while [ $month_last_day -gt 0 ]; do
	for (( j=0; j<7; j++ )); do
		if [ $month_begin_with -gt 1 ]; then
			echo -ne "\t";
			month_begin_with=$(($month_begin_with-1));
			continue;
		fi;
		if [ $month_last_day -eq 0 ]; then
			break;
		fi;
		difference=$(($data-1359655200));
		difference=$(($difference/86400+1));
		result="р";
		for (( k=0; $k<$difference; k=$k+2 )); do
			if [ "$result" = "в" ]; then result="р"; continue; fi;
			if [ "$result" = "р" ]; then result="в"; continue; fi;
		done;
#Вывод результата по одному дню за цикл
		echo -ne "`date --date=\"@$data\" +%d`$result\t";
		data=$(($data+86400));
		month_last_day=$(($month_last_day-1));
	done;
	echo;
done;
echo;
exit;
}

#Инициализация переменных для текущей даты
day=`date +%d`;
month=`date +%m`;
year=`date +%Y`;

#Считывание позиционных параметров
pos_param=$#;
if [ $pos_param = 0 ]; then
	single_date nodata;
fi;
param=$1;
case $param in
	( -d | --date )
		shift;
		param=$1;
		if [ "${#param}" -eq 8 ]; then
			day="${param:0:2}";
			month="${param:3:2}";
			year="${param:6:2}";
		elif [ "${#param}" -eq 5 ]; then
			day="${param:0:2}";
			month="${param:3:2}";
		elif [ "${#param}" -eq 2 ]; then
			day=$param;
		fi;
		data=`date --date="$year-$month-$day" +%s`;
		single_date $data;;
	( -c | --calendar )
		shift;
		param=$1;
		if [ "${#param}" -eq 5 ]; then
			month="${param:0:2}";
			year="${param:3:2}";
		elif [ "${#param}" -eq 2 ]; then
			month=$param;
		fi;
		data=`date --date="$year-$month-01" +%s`;
		calendar $data;;
	( -h | --help )
		help;;
	( * )
		usage;;
esac;
