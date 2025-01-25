include 'emu8086.inc'
.model small
.stack 100h
.data
    ; Utilities
    newLine          db 10, 13, "$" ; Newline

    ; Login Page
    l1 db 13, 10, "**************************************************$" 
    l2 db 13, 10, "**                  Admin Login                 **$" 
    l3 db 13, 10, "**************************************************$" 

    askUsername db "Enter Username: $" 
    askPassword db "Enter Password: $" 

    loginSuccessMsg db "Login Successful! $" 
    loginErrorMsg db "Login Failed! (Press Any Key to Continue) $"

    username db "admin" ; Predefined username
    password db "admin" ; Predefined password

    inUsername db 10 dup("$") ; Buffer for input username (10 characters max)
    inPassword db 10 dup("$") ; Buffer for input password (10 characters max)

    ; Main Menu
    m1 db 13, 10, "**************************************************$" 
    m2 db 13, 10, "**                   Employee                   **$" 
    m3 db 13, 10, "**                  Management                  **$" 
    m4 db 13, 10, "**                    System                    **$" 
    m5 db 13, 10, "**************************************************$"

    ; Main Menu Options
    mmOption1        db 13, 10, "1. Add Employee $"
    mmOption2        db 13, 10, "2. Delete Last Added Employee $"
    mmOption3        db 13, 10, "3. Show All Employees $"
    mmOption4        db 13, 10, "4. Logout $"
    mmOption5        db 13, 10, "5. Exit Program $"
    mmChoice         db 13, 10, "Enter Your Choice: $"

    ; Employee Data Storage
    empCount         db 0                       ; Count of employees added
    empNames         db 10 dup(30 dup('$'))     ; Storage for 10 employee names, each 30 characters max
    empEmails        db 10 dup(30 dup('$'))     ; Storage for 10 employee emails, each 30 characters max
    empPhones        db 10 dup(30 dup('$'))     ; Storage for 10 employee phones, each 30 characters max

    askEmployeeName  db 10, 13, "Name: $"
    askEmployeeEmail db 10, 13, "Email: $"
    askEmployeePhone db 10, 13, "Phone: $"

    deleteSuccessMsg db 10, 13, "Employee deleted successfully!$"
    invalidSerialMsg db "Invalid Serial Number!$"
    noEmployeesDelMsg   db "No employees to delete.$"
    noEmployeesShowMsg   db "No employees to show.$"
    employeeHeader   db "Employee List:$"
    
    tab              db "    |    $"

    ; Add Page
    a1 db 13, 10, "**************************************************$" 
    a2 db 13, 10, "**                  Add Employee                **$" 
    a3 db 13, 10, "**************************************************$"

    ; Delete Page
    d1 db 13, 10, "**************************************************$" 
    d2 db 13, 10, "**                Delete Employee               **$" 
    d3 db 13, 10, "**************************************************$"
    
    ; Show All Page
    s1 db 13, 10, "**************************************************$" 
    s2 db 13, 10, "**                 Employee List                **$" 
    s3 db 13, 10, "**************************************************$"
    
.code
main proc
    mov   ax, @data
    mov   ds, ax

    call DisplayLoginPage
    call ValidateLogin       
    call  DisplayMainMenu
main endp

;-------------------------------------------------

DisplayLoginPage proc
    ; Display login page header
    mov ah, 9
    lea dx, l1
    int 21h
    lea dx, l2
    int 21h
    lea dx, l3
    int 21h
    lea dx, newLine
    int 21h

    print 'Enter Username: '

    ; Get username input from user
    mov si, offset inUsername
InputUsername:
    mov ah, 1
    int 21h
    cmp al, 13      ; Comapare with Enter key
    je DoneUsername
    mov [si], al
    inc si
    jmp InputUsername
DoneUsername:

    ; Prompt for password
    mov ah, 9
    lea dx, newLine
    int 21h
    
    print 'Enter Password: '

    ; Get password input from user
    mov si, offset inPassword
InputPassword:
    mov ah, 1
    int 21h
    cmp al, 13
    je DonePassword
    mov [si], al
    inc si
    jmp InputPassword
DonePassword:
    ret
DisplayLoginPage endp

;-------------------------------------------------

ValidateLogin proc
    ; Validate username
    mov si, offset username
    mov di, offset inUsername
    mov cx, 5
LoginValidationUsername:
    mov bl, [si]
    mov dl, [di]
    cmp bl, dl
    jne InvalidLogin
    inc si
    inc di
    loop LoginValidationUsername

    ; Validate password
    mov si, offset password
    mov di, offset inPassword
    mov cx, 5
LoginValidationPassword:
    mov bl, [si]
    mov dl, [di]
    cmp bl, dl
    jne InvalidLogin
    inc si
    inc di
    loop LoginValidationPassword

    ; Display success message
    mov ah, 9
    lea dx, newLine
    int 21h
    lea dx, newLine
    int 21h
    
    print 'Login Successful!'
    ret

InvalidLogin:
    ; Display error message
    mov ah, 9
    lea dx, newLine
    int 21h

    print 'Login Failed! (Press Any Key to Continue)'

    ; Wait for key press
    mov ah, 1
    int 21h
    jmp main
ValidateLogin endp

;-------------------------------------------------

Logout proc
    ; Clear input buffers 
    mov di, offset inUsername
    mov cx, 10
    mov al, '$'     ; Initiate all index with $
ClearBufferLoop:
    mov [di], al
    inc di
    loop ClearBufferLoop

    ; Restart login process
    call DisplayLoginPage
    call ValidateLogin
    call DisplayMainMenu
    ret
Logout endp

;-------------------------------------------------

DisplayMainMenu proc
     ; Display Main Menu header and options
    mov ah, 9
    lea dx, m1
    int 21h
    lea dx, m2
    int 21h
    lea dx, m3
    int 21h
    lea dx, m4
    int 21h
    lea dx, m5
    int 21h
    lea dx, newLine
    int 21h

    lea   dx, mmOption1
    int   21h

    lea   dx, mmOption2
    int   21h
    
    lea   dx, mmOption3
    int   21h

    lea   dx, mmOption4
    int   21h
    
    lea   dx, mmOption5
    int   21h

    lea   dx, mmChoice
    int   21h

    mov   ah, 1
    int   21h

    cmp   al, '1'
    je    AddEmployee

    cmp   al, '2'
    je    DeleteEmployee
                     
    cmp   al, '3'
    je    ShowAllEmployees

    cmp   al, '4'
    je    Logout
    
    cmp   al, '5'
    je    ExitProgram

    jmp   DisplayMainMenu
DisplayMainMenu endp

;-------------------------------------------------

DeleteEmployee proc
    mov   al, empCount
    cmp   al, 0
    je    NoEmployeesToDelete

    mov ah, 9
    lea dx, d1
    int 21h
    lea dx, d2
    int 21h
    lea dx, d3
    int 21h

    call NL 
    print "0. Back"
    call NL
    print "1. Delete"
    call NL
    print 'Enter Choice: '

    mov   ah, 1
    int   21h

    sub   al, '0'   ; Convert ASCII to number
    cmp   al, 0
    je    DisplayMainMenu

    cmp   al, empCount
    ja    InvalidSerial       

    dec empCount      ; Decrement employee count
    
    call NL 
    call NL 
    print 'Employee deleted successfully!'
    call NL 
    jmp   DisplayMainMenu

InvalidSerial:      

    call NL
    print "Invalid Option!"
    call NL
    jmp   DisplayMainMenu

NoEmployeesToDelete: 
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, noEmployeesDelMsg
    int   21h
    jmp   DisplayMainMenu
DeleteEmployee endp

;-------------------------------------------------

AddEmployee proc
    mov   al, empCount
    cmp   al, 10          ; Limit to 10 employees
    jae   MaxEmployees    

    mov ah, 9
    lea dx, a1
    int 21h
    lea dx, a2
    int 21h
    lea dx, a3
    int 21h

    EmployeeName:    
    ; Prompt for Employee Name
    mov   ah, 9
    lea   dx, newLine
    int   21h
   
    print 'Name: '

    ; Store name into empNames array
    mov   si, offset empNames
    mov   bl, empCount   ; Get current employee index
    mov   bh, 0
    mov   di, bx         ; Move index to DI

    mov   ax, bx        ; Move the employee index into AX (AX is required for mul)
    mov   cx, 30        ; Set multiplier to 30

    mul   cx            ; AX = AX * CX (index * 30), result stored in DX:AX

    add   si, ax        ; Add the calculated offset to the base address in SI
    call  GetInput      ; Get input and store it at the calculated address
    call  NL

    EmployeeEmail:   
    ; Prompt for Employee Name
    print 'Email: '

    ; Store name into empNames array
    mov   si, offset empEmails
    mov   bl, empCount    ; Get current employee index
    mov   bh, 0
    mov   di, bx          ; Move index to DI

    mov   ax, bx        ; Move the employee index into AX (AX is required for mul)
    mov   cx, 30        ; Set multiplier to 30

    mul   cx            ; AX = AX * CX (index * 30), result stored in DX:AX

    add   si, ax        ; Add the calculated offset to the base address in SI
    call  GetInput      ; Get input and store it at the calculated address
    call  NL
    
    EmployeePhone:   
    ; Prompt for Employee Name

    print 'Phone: '

    ; Store name into empNames array
    mov   si, offset empPhones
    mov   bl, empCount   ; Get current employee index
    mov   bh, 0
    mov   di, bx        ; Move index to DI

    mov   ax, bx     ; Move the employee index into AX (AX is required for mul)
    mov   cx, 30     ; Set multiplier to 30

    mul   cx        ; AX = AX * CX (index * 30)

    add   si, ax        ; Add the calculated offset to the base address in SI
    call  GetInput      ; Get input and store it at the calculated address

    call  NL

    ; Increment employee count
    inc empCount
    
    call NL
    print 'Employee added successfully!'
    jmp   DisplayMainMenu

    MaxEmployees:    
    ; Display message when max employee limit is reached
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, employeeHeader
    int   21h
    jmp   DisplayMainMenu
AddEmployee endp

;-------------------------------------------------

GetInput proc
    InputLoop:       
    mov   ah, 1         
    int   21h
    cmp   al, 13        ; Check if Enter key pressed
    je    DoneInput
    
    mov   [si], al      
    inc   si
    jmp   InputLoop

    DoneInput:       
    mov [si], '$'      ; Terminate string with '$'
    ret
GetInput endp

;-------------------------------------------------

ShowAllEmployees proc
    mov   al, empCount
    cmp   al, 0
    je    NoEmployees

    mov ah, 9
    lea dx, s1
    int 21h
    lea dx, s2
    int 21h
    lea dx, s3
    int 21h
    lea dx, newLine
    int 21h
     

    ; Display header row
    print 'SNo  |    '
    
    print 'Name'
    lea   dx, tab
    int   21h
    

    print 'Email'
    lea   dx, tab
    int   21h
    
    print 'Phone'
    lea   dx, newLine
    int   21h

    ; Display employee details
    xor   cx, cx            ; Clear cx for empCount
    mov   cl, empCount      
    xor   bp, bp            ; Reset bp for serial number counter
    inc   bp                ; Start serial number from 1

    mov   si, offset empNames
    mov   bx, offset empEmails
    mov   di, offset empPhones

    DisplayLoop:     
    ; Display serial number
    mov   ax, bp    
    mov   dl, al    
    add   dl, '0'   ; Convert to Decimal -> ASCII
    mov   ah, 2     
    int   21h
    
    mov   ah, 9
    lea   dx, tab      
    int   21h


    ; Display employee name
    mov   ah, 9
    lea   dx, [si]
    int   21h

    lea   dx, tab
    int   21h

    ; Display employee email
    mov   ah, 9
    lea   dx, [bx]
    int   21h
    
    lea   dx, tab
    int   21h

    ; Display employee phone
    mov   ah, 9
    lea   dx, [di]
    int   21h
    
    lea   dx, newLine
    int   21h

    ; Move to the next employee record
    add   si, 30    ; Move to next name record
    add   bx, 30    ; Move to next email record
    add   di, 30    ; Move to next phone record
    inc   bp        ; Increment serial number
 
    loop  DisplayLoop

    jmp   DisplayMainMenu

    NoEmployees:     
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, noEmployeesShowMsg
    int   21h
    jmp   DisplayMainMenu
ShowAllEmployees endp

;-------------------------------------------------

NL proc     ; Newline Function
    mov   dl, 13
    mov   ah, 02h
    int   21h
    mov   dl, 10
    mov   ah, 02h
    int   21h
    ret     
NL endp

;-------------------------------------------------

    ExitProgram:     
    mov   ah, 4ch
    int   21h
end main
