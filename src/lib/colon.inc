%ifndef COLON

%define CURRENT_START 0

%macro colon 2

    %ifid %2
        %2: dq CURRENT_START
        %define CURRENT_START %2
    %else
        %error ERROR on creation node %2: second arg must be label 
    %endif

    %ifstr %1
        db %1, 0
    %else
        %error on creation node %2: key must be string
    %endif
    
%endmacro

%define COLON
%endif