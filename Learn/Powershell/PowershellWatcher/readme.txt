
+++++++ config.json
+++ version [string]
+++ actions
name - action name [string] simple
value - any variables that needed to action
status - action status [enum] (comment: execution priority - ep)
 + notrun - must be run once
 + succes - once run action that has been runned
 + perpetum - action that must be runned every time main script execution
 + perpetumwait - action runned every time but only if no other actions must be runned
after - after action execution behaviour 
 + stop - execute action and stop
 + continue - execute and continue (default)
 + stopifexception - execute and stop if exception occur
 + stopifsucces - execute and stop if execution succes
 + continueifexecption - 
 + continueifsucces - 
order - action execution order
