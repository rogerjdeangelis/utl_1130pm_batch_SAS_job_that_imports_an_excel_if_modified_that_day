Execute a 11:30pm batch SAS job that imports an excel file it was modified ealier in the day

  Chron documentation on end of message also all file infor functions

  INPUT

     d:/xls/class.xlsx  sheetname class (substitute 'sheet1$'n  fo defaults)

   PROCESS
   =======

     COMPILE TIME DOSUBL
     * create macro variable with lat modified date;

        filename fileref "d:/xls/class.xlsx";
        data _null_;
           infile fileref truncover obs=1;
           fid=fopen("fileref");
           modDte=finfo(fid,"Last Modified");
           call symputx("cmodDte",substr(modDte,1,9));
        run;quit;
        filename fileref clear;

        %put "&cmodDte";

        "30Oct2017"

     MAINLINE (see if modified today;

        if today() eq "&cmodDte"d then do;

        DOSUBL (save workbook in date stamed SAS dataset

           rc=dosubl('
             libname xel "d:\xls\class.xlsx";
             data class_&cmodDte;
                set xel.class;
         ');

     MAINLINE

         end;

   OUTPUT
   ======

      WORK.CLASS_30OCT2017


see
https://goo.gl/bTs93G
https://communities.sas.com/t5/Base-SAS-Programming/Help-Excel-file-check-in-windows-sas/m-p/408836


HAVE
====
   workbook modifies sometime today

   d:/xls/class.xlsx  sheetname class (substitute 'sheet1$'n  fo defaults)

WANT
====
   If modified today than create timestamped SAS dataset

   WORK.CLASS_30OCT2017

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

%utlfkil(d:/xls/class.xlsx);
libname xel "d:/xls/class.xlsx";
data xel.class;
  set sashelp.class;
run;quit;
libname xel clear;

* just in case you want to rerun;
proc datasets lib=work kill noprint;
run;quit;
%symdel modDte cmodDte / nowarn;
libname xef clear;
libname fileref clear;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

data _null_;

     * get last modified Dte;
     if _n_=0 then do;
        %let rc=%sysfunc(dosubl('
             filename fileref "d:/xls/class.xlsx";
             data _null_;
                infile fileref truncover obs=1;
                fid=fopen("fileref");
                modDte=finfo(fid,"Last Modified");
                call symputx("cmodDte",substr(modDte,1,9));
             run;quit;
             filename fileref clear;
        '));
      end;

     if today() eq "&cmodDte"d then do;
        rc=dosubl('
          libname xel "d:\xls\class.xlsx";
          data class_&cmodDte;
             set xel.class;
          run;quit;
          libname xel clear;
      ');
     end;

     stop;

run;quit;

LOG

NOTE: Fileref FILEREF has been deassigned.
3638                  modDte=finfo(fid,"Last Modified");
3639                  call symputx("cmodDte",substr(modDte,1,9));
3640               run;quit;
3641               filename fileref clear;
3642          '));
3643        end;
3644       if today() eq "&cmodDte"d then do;
SYMBOLGEN:  Macro variable CMODDTE resolves to 30Oct2017
3645          rc=dosubl('
3646            libname xel "d:\xls\class.xlsx";
3647            data class_&cmodDte;
3648               set xel.class;
3649            run;quit;
3650            libname xel clear;
3651        ');hen do;
3652       end;=%sysfunc(dosubl('
3653       stop;_null_;
3654  run;

NOTE: Libref XEL was successfully assigned as follows:
      Engine:        EXCEL
      Physical Name: d:\xls\class.xlsx
SYMBOLGEN:  Macro variable CMODDTE resolves to 30Oct2017
NOTE: There were 19 observations read from the data set XEL.class.
NOTE: The data set WORK.CLASS_30OCT2017 has 19 observations and 5 variables.

*     _                         _       _
  ___| |__  _ __ ___  _ __     (_) ___ | |__  ___
 / __| '_ \| '__/ _ \| '_ \    | |/ _ \| '_ \/ __|
| (__| | | | | | (_) | | | |   | | (_) | |_) \__ \
 \___|_| |_|_|  \___/|_| |_|  _/ |\___/|_.__/|___/
                             |__/
;

/* T004680 SETTING UP CHRON JOBS ON UNIX AND WINDOWS

This is a very old tip circa Win 2000(updated today for Win 7)

start>Control Panel\System and Security\Administrative Tools\scheduled tasks

put the following in run dialog box
C:\Program Files\SAS\SAS 9.1\sas.exe" -nosplash -sysin c:\sas\pgm.sas -log nul: -print nul:
put the following in start in box
c:\sas

You don't have to have a null log and list.
I send an email with the log and list when the program fails

IN UNIX

create a file called cronjob.txt with just the line below

0 2 * * 1-5 /groundtruth/programs/program.csh

Details
mm hh dd mon day
0   2  *  *  1-5 /groundtruth/programs/program.csh

run at 2am every monday-friday

here is what program.csh looks like(executes sas myprogram
#!/usr/bin/csh
cd /groundtruth/sas/programs
/groundtruth/local/bin/sas mysasprogram

You can execute crontab if your name appears in the file /usr/lib/cron/cron.allow

crontab -e      Edit your crontab file, or create one if it doesn?t already exist.
crontab -l      Display your crontab file.
crontab -r      Remove your crontab file.
crontab -v      Display the last time you edited your crontab file.

* __ _        __
 / _(_)_ __  / _| ___
| |_| | '_ \| |_ / _ \
|  _| | | | |  _| (_) |
|_| |_|_| |_|_|  \___/

;
http://support.sas.com/kb/40/934.html

%macro FileAttribs(filename);
   %local rc fid fidc;
   %local Bytes CreateDT ModifyDT;
   %let rc=%sysfunc(filename(onefile,&filename));
   %let fid=%sysfunc(fopen(&onefile));
   %let Bytes=%sysfunc(finfo(&fid,File Size (bytes)));
   %let CreateDT=%qsysfunc(finfo(&fid,Create Time));
   %let ModifyDT=%qsysfunc(finfo(&fid,Last Modified));
   %let fidc=%sysfunc(fclose(&fid));
   %let rc=%sysfunc(filename(onefile));
   %put NOTE: File size of &filename is &Bytes bytes;
   %put NOTE- Created &CreateDT;
   %put NOTE- Last modified &ModifyDT;
%mend FileAttribs;

/** Just pass in the path and file name **/
%FileAttribs(c:\aaa.txt)


