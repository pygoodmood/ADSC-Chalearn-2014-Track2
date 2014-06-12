clear;clc;

inputvideoname = 'C:/Users/Desktop/Teste/Seq07_color.mp4';
outputfilename = 'Seq07_prediction.csv';
main_func( inputvideoname,outputfilename );


inputvideoname = 'C:/Users/Desktop/Teste/Seq05_color.mp4';
outputfilename = 'Seq05_prediction.csv';
main_func( inputvideoname,outputfilename );

zip('Submission.zip','*.csv');