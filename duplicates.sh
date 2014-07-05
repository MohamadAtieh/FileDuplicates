#!/bin/sh

#check if parameters passed is exactly 1 
if [ $# -ne 1 ]  
then
 echo "Usage: $0 <Directory Name or its Path Name>" >&2
 exit 1
fi

if [ -e $1 ] 
then
#initialize variables
total=0
groupdup=0
mkdir duplicates_directory

#storing only the md5 hash in an array 
all=( $(find $1 -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate | cut -c -32)  ) 

#storing only the path name in an array
filenames=( $(find $1 -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate | cut -c 35-)  ) 

#iterating through the hashes to compare
for ((i = 0;i < ${#all[@]};i++))
do 
if [ ${all[i]} == ${all[i-1]} ] #if the current is equal to the preceding hash, then it's a duplicate ELSE: it's a header (original)
then
#echo ${all[i]} ${filenames[i]}
((total++))
((groupdup++)) 

du ${filenames[i]} -h #print the file size and path  ......
cp ${filenames[i]} duplicates_directory #copy to this directory

else
if [ $groupdup -ne 0 ] 
then
echo 'Number of duplicates is' $groupdup   #number of duplicates in one group
groupdup=0
fi
echo '-----------------HEADER:' ${filenames[i]} '------------------'
fi
done
echo 'Number of duplicates is' $groupdup #number of duplicates in the last group 

echo ''
echo ''
echo 'Total number of duplicates is ' $total  #total number of duplicates


echo -n 'Total duplicates size is ' 
echo
find duplicates_directory | xargs du -h -c #total duplicate sizes
rm -Rf duplicates_directory 

else
echo "The file '$1' does not exist"
fi

#for ((i = 0 ; i < ${#filenames[@]} ; i++ ))
#do
#find ${filenames[i]} | xargs du -hc 
#done









