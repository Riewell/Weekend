#!/bin/bash
#
#  Вычисление выходных и рабочих дней при графике работы 2/2
#  (Отсчёт ведётся с 1 февраля 2013 г. - выходной день)
#  Version 1.0
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
echo "Использование: $0 [[-d|--date] ДАТА] [-c|--calendar] [-h|--help]";
exit;
}

#Функция вывода краткой справки
help() {
echo;
echo "Использование: "
echo "$0 [[-d|--date] ДАТА] [-c|--calendar [МЕСЯЦ]] [-h|--help]";
echo;
echo "  [-d|--date] ДАТА		Вывод результата на определённую пользователем";
echo "				ДАТУ, заданную в формате ДД.ММ.ГГ";
echo;
echo "  -c|--calendar [МЕСЯЦ]		Вывод результата в виде календаря";
echo "				на определённый пользователем МЕСЯЦ,";
echo "				заданный в формате ММ или ММ.ГГ"
echo;
echo "  -h|--help			Показать эту справку и выйти";
echo;
exit;
}

#Считывание позиционных параметров
pos_param=$#;
if [ $pos_param != 0 ]; then
	param=$1;
	case $param in
		( -d | --date )
			shift;
			#if [ "${#$1}" -lt 8 ]; then
			day="${$1:0:2}";
			month="${$1:3:2}";
			year="${$1:6:2}";
			#if 
		( -c | --calendar )
			calendar=1;
			shift;
			if [ -n "$1" ]; then calendar_month=$1; fi;;
		( -h | --help)
			help;;
		( * )
			
	esac;
fi;

echo -n "Введите дату [ДД.ММ.ГГ]: ";
read data;
day="${data:0:2}";
month="${data:3:2}";
year=20"${data:6:2}";
data=`date --date="$year-$month-$day" +%s`;
difference=$(($data-1359655200));
difference=$(($difference/86400+1));
result=1;
for (( i=0; $i<$difference; i=$i+2 )); do
	if [ $result -eq 0 ]; then result=1; continue; fi;
	if [ $result -eq 1 ]; then result=0; continue; fi;
done;
case $result in
	0 ) echo "Выходной";;
	1 ) echo "Рабочий";;
esac;
