rem config
@java -jar ..\kickass\kickass.jar game.asm
@echo %ERRORLEVEL%
@IF %ERRORLEVEL% NEQ 0 GOTO ERROR_HANDLER
@exomizer.exe sfx basic,2049 game.prg -o reset4k.prg
@goto quit

:ERROR_HANDLER


:QUIT
@echo "end"

