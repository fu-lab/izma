# This code is found from https://code.activestate.com/recipes/577423-convert-csv-to-xml/?c=15741
import sys
import os
import csv
if len(sys.argv) != 2:
    os._exit(1)
path=sys.argv[1] # get folder as a command line argument
os.chdir(path)
csvFiles = [f for f in os.listdir('.') if f.endswith('.csv') or f.endswith('.CSV')]
for csvFile in csvFiles:
    xmlFile = csvFile[:-4] + '.xml'
    csvData = csv.reader(open(csvFile))
    xmlData = open(xmlFile, 'w')
    xmlData.write('<?xml version="1.0"?>' + "\n")
    # there must be only one top-level tag
    xmlData.write('<data>' + "\n")
    rowNum = 0
    for row in csvData:
        if rowNum == 0:
            tags = row
            # replace spaces w/ underscores in tag names
            for i in range(len(tags)):
                tags[i] = tags[i].replace(' ', '_')
        else: 
            xmlData.write('<row>' + "\n")
            for i in range(len(tags)):
                xmlData.write('    ' + '<' + tags[i] + '>' \
                              + row[i] + '</' + tags[i] + '>' + "\n")
            xmlData.write('</row>' + "\n")                
        rowNum +=1
    xmlData.write('</data>' + "\n")
    xmlData.close()
