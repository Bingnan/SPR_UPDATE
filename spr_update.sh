#!/bin/bash
#Program:
#    This script is to update SPR version and date info in setting baseline code
#History:
#    23-05-12 Bingnan Duan(david.3.duan@nokia.com) Initial version

read -p "Please enter new SPR version code (for example: V 03.03,V 03.07...)" SPR_VERSION
echo New SPR Version code: $SPR_VERSION

read -p "Please enter new date (for example: 10-05-12,03-04-12...)" SPR_DATE
echo New SPR Date: $SPR_DATE

mkdir ./SPR_TEMP

ls ../ | grep 'defaults' > list.txt

cat list.txt | while read region_line
do
    echo default region line: $region_line
    ls ../$region_line | grep '05' | tee one_region_variant_code.txt

    cat one_region_variant_code.txt | while read Variant_Line
        do 
            echo /=============================BEGIN========================================/
            
            echo Variant line:$Variant_Line
            
            Variant_Code=${Variant_Line:0:7}            
            echo Varinat code:$Variant_Code
            
            SPR_FILE_NAME=RM811_${Variant_Code}.SPR            
            echo SPR FILE NAME:$SPR_FILE_NAME
            
            echo Unzip old spr file
            mkdir ./SPR_TEMP/$Variant_Code
            unzip -n ../$region_line/$Variant_Line/EXT_DCP_FILES/$SPR_FILE_NAME -d ./SPR_TEMP/$Variant_Code
            
            echo Modify ContentPackageVersionVerifier_v1.0.xml
            sed -i '3c '"$SPR_VERSION"'' ./SPR_TEMP/$Variant_Code/ContentPackageVersionVerifier_v1.0.xml
            sed -i '4c '"$SPR_DATE"'' ./SPR_TEMP/$Variant_Code/ContentPackageVersionVerifier_v1.0.xml
            
            echo Modify McuSwVersionVerifier_v1.0.xml            
            sed -i 's/V .*$/'"$SPR_VERSION"'/g' ./SPR_TEMP/$Variant_Code/McuSwVersionVerifier_v1.0.xml
            sed -i '3c '"$SPR_DATE"'' ./SPR_TEMP/$Variant_Code/McuSwVersionVerifier_v1.0.xml
            
            echo Modify PpmInfoVerifier_v1.0.xml
            sed -i 's/V .*$/'"$SPR_VERSION"'/g' ./SPR_TEMP/$Variant_Code/PpmInfoVerifier_v1.0.xml
            sed -i '3c '"$SPR_DATE"'' ./SPR_TEMP/$Variant_Code/PpmInfoVerifier_v1.0.xml
            
            echo Zip .xml files
            cd ./SPR_TEMP/$Variant_Code/
            zip $SPR_FILE_NAME *.*
            
            echo Move new SPR file into orignal folder.
            mv $SPR_FILE_NAME ../../../$region_line/$Variant_Line/EXT_DCP_FILES/            
            cd ../../
            
            echo /=============================END========================================/ 
        done
    rm -f one_region_variant_code.txt
done

rm -f list.txt
