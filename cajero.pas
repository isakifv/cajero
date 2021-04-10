Uses crt;

Const

//Este valor representa la cantidad maxima de usuarios que el programa soporta, puede ser modificado en cualquier momento
  max = 10;
  movs = 20;
  nombre_archivo = 'database.txt';
  nomb_mov = 'movimientos.txt';
Type
  mov = Record
    tipo: String;
    valor: Double;
    receptor: Integer;
  End;
  list_mov = Array [1..movs] Of String;
  reg_mov = Array [1..movs] Of mov;
  usuario = Record
    cedula: Integer;
    Nombre, apellido: String[15];
    saldo: Real;
    posc: Integer;
    movimientos: reg_mov;
    cant_mov: Integer;
    password: String;
  End;
  usuarios = Array [1..max] Of usuario;
  z = file Of list_mov;
Var
  f: Text;
  list_us: usuarios;
  op: Integer;
  client_dat: file Of usuarios;

//Esta funcion da un vaor booleano como resultado. Verdadero si el archivo existe y falso si no. El argumento es el nombre del archivo que se busca verificar

Function fileExist (nombre:String): Boolean;
Var
  f: Text;
Begin
  Assign(f,nombre);
 {$I-}
  Reset(f);
 {$I+}
  If (Ioresult=0) Then
    Begin
      Close(f);
      FileExist := True;
    End
  Else
    FileExist := False;
End;
//Inicializa los valores de cédula del arreglo para evitar problemas con valores no inicializados

Procedure init(list_us:usuarios);
Var
  i: Integer;
Begin
  i := 1;
  Repeat
    list_us[i].cedula := 0;
    i := i+1;
  Until (i=max);
End;

//Verifica la existencia de un numero de cedula en la base de datos de los usuarios. Da positivo si al cedula ya fue registrada y negativo sino

Function verif_ced(ced:Integer; list_us:usuarios): Boolean;
Var
  i: Integer;
  b: Boolean;
Begin
  i := 1;
  b := False;
  If (ced<>0) Then
    Begin
      Repeat
        If (ced=list_us[i].cedula) Then
          Begin
            b := True;
            verif_ced := b;
            Exit;
          End;
        i := i+1;
      Until (i=max);
    End;
  verif_ced := b;
End;

//Devuelve la posición de un usuario en el arreglo de la base de datos usando su cedula y la base de datos como argumentos

Function ob_posc(ced:Integer; list_us:usuarios): Integer;
Var
  i: Integer;
Begin
  Repeat
    If (list_us[i].cedula=ced) Then
      Begin
        ob_posc := i;
        Exit;
      End;
    i := i+1;
  Until (i=max);
End;
//Es el modulo encargado de registrar un usuario nuevo en la base de datos

Procedure reg_us(Var list_us:usuarios);
Var
  ced,i,j: Integer;
  cond: Boolean;
Begin
  Writeln('Sistema de registro de usuario.');
  Repeat
    Writeln('Introduzca su cédula:');
    Writeln('Introduzca 0 para cancelar el registro.');
    Readln(ced);
    cond := verif_ced(ced, list_us);
    If ((cond=True)Or((ced<1000000)Or(ced>99999999)))Then
      Begin
        Writeln('Su cédula ya existe en el sistema, porfavor iniciar sesión.');
      End;
  Until (cond=False)Or(ced=0);
  If (cond=False)And(Not(((ced<1000000)Or(ced>99999999)))) Then
    Begin
      i := 0;
      Repeat
        i := i+1;
      Until (list_us[i].cedula=0);
      list_us[i].cedula := ced;
      Writeln('Registro de datos del ciudadano:', ced);
      Writeln('Introduzca su nombre:');
      Readln(list_us[i].nombre);
      Writeln('Introduzca su apellido:');
      Readln(list_us[i].apellido);
      list_us[i].posc := i;
      Writeln('Introduzca la clave que desea tener. Puede utilizar letras, números y simbolos.');
      Readln(list_us[i].password);
      Writeln('Nombre:',list_us[i].nombre, '      |      Apellido:', list_us[i].apellido);
      Writeln('Cédula: ', list_us[i].cedula,'      |      Contraseña: ', list_us[i].password);
      Writeln('Saldo:', list_us[i].saldo:0:2,'Bs.f',

'. Para tener un saldo distinto de cero, realice su primer deposito o reciba su primera transferencia'
      );
      Readkey;
    End;
End;
//Es el módulo encargado de los depositos

Procedure dep (ced:Integer; Var list_us:usuarios; posc:Integer);
Var
  valid: Boolean;
  valor: Integer;
  movimiento: mov;
  m: String;
Begin
  Writeln('Introduzca el valor de su deposito');
  Writeln('Saldo de la cuenta:',list_us[posc].saldo:0:2,'Bs.f');
  Repeat
    Readln(valor);
    If (valor<0)Then Writeln('Valor invalido, tiene que ser mayor a 0');
  Until (valor>0);
  movimiento.tipo := 'Deposito';
  movimiento.valor := valor;
  list_us[posc].cant_mov := (list_us[posc].cant_mov + 1);
  list_us[posc].movimientos[list_us[posc].cant_mov] := movimiento;
  list_us[posc].saldo := list_us[posc].saldo + valor;
  Writeln('Deposito realizado exitosamente.');
  Writeln('Saldo de la cuenta:',list_us[posc].saldo );
End;
//Modulo encargado de los retiros

Procedure ret (ced:Integer; Var list_us:usuarios; posc:Integer);
Var
  valid: Boolean;
  valor: Integer;
  movimiento: mov;
  op: Integer;
Begin
  If ((list_us[posc].saldo<>0)And(list_us[posc].saldo>1000)) Then
    Begin
      Writeln('Introduzca el valor de su retiro. Opciones:');
      Writeln('1-. Retiro de 1.000bsf.');
      Writeln('1-. Retiro de 2.000bsf.');
      Writeln('1-. Retiro de 10.000bsf.');
      Writeln('1-. Retiro de 20.000bsf.');
      Writeln('1-. Retiro de 50.000bsf.');
      Writeln('Saldo de la cuenta:',list_us[posc].saldo:0:2,'Bs.f');
      Repeat
        Readln(op);
        Case op Of
          1:
             Begin
               Writeln('Realizando retiro de 1.000bs.');
               valor := 1000;
             End;
          2:
             Begin
               Writeln('Realizando retiro de 2.000bs.');
               valor := 2000;
             End;
          3:
             Begin
               Writeln('Realizando retiro de 10.000bs.');
               valor := 10000;
             End;
          4:
             Begin
               Writeln('Realizando retiro de 20.000bs.');
               valor := 20000;
             End;
          5:
             Begin
               Writeln('Realizando retiro de 50.000bs.');
               valor := 50000;
             End
             Else
               Writeln('Opción inválida.');
        End;
        If (Not valor<=list_us[posc].saldo)Then Writeln(

                                  'El valor que intenta retirar es mayor al existente en su cuenta.'
          );
      Until (((op>0) And (op<5))And(valor<=list_us[posc].saldo));
      Readln;
      movimiento.tipo := 'Retiro';
      movimiento.valor := valor;
      list_us[posc].cant_mov := (list_us[posc].cant_mov + 1);
      list_us[posc].movimientos[list_us[posc].cant_mov] := movimiento;
      list_us[posc].saldo := list_us[posc].saldo - valor;
      Writeln('Retiro realizado exitosamente.');
      Writeln('Saldo de la cuenta:',list_us[posc].saldo:0:2,'Bs.f');
    End
  Else
    Begin
      If (list_us[posc].saldo<1000)Then Writeln(

                           'No tiene el saldo suficiente para realizar el retiro mínimo (1.000bs).'
        )
      Else Writeln('La cuenta seleccionada no tiene saldo alguno para ser retirado o transferido.');
      Writeln(

'--------------------------------------------------------------------------------------------------'
      );
      Exit;
    End;
  Writeln(

'--------------------------------------------------------------------------------------------------'
  );
End;
//Modulo encargado de las transferencias

Procedure trans(ced:Integer; Var list_us:usuarios; posc:Integer);
Var
  posc2: Integer;
  valid: Boolean;
  valor: Integer;
  movimiento: mov;
  ced2: Integer;
  x: String;
Begin
  If (list_us[posc].saldo<>0)Then
    Begin
      Writeln('Introduzca la cédula de la persona a la que quiere transferir los fondos.');
      Repeat
        Readln(ced2);
        If (verif_ced(ced2, list_us)=False)Then Writeln(

                                                    'Valor invalido,introduzca una cédula válida.'
          );
      Until (verif_ced(ced2, list_us)=True);
      posc2 := ob_posc(ced2, list_us);
      Writeln('Cuenta a transferir: ',list_us[posc2].nombre,' ', list_us[posc2].apellido,'.' );
      Writeln('Introduzca el valor de su transferencia.');
      Writeln('Saldo de la cuenta:',list_us[posc].saldo:0:2,'Bs.f');
      Repeat
        Readln(valor);
        If (valor>list_us[posc].saldo)Then Writeln(

                       'Valor invalido, tiene que ser mayor a 0 y menor o igual que su saldo total.'
          );
      Until ((valor>0) And (valor<=list_us[posc].saldo));
      movimiento.tipo := 'Transferencia';
      movimiento.valor := valor;
      movimiento.receptor := ced2;
      list_us[posc].cant_mov := (list_us[posc].cant_mov + 1);
      list_us[posc].movimientos[list_us[posc].cant_mov] := movimiento;
      list_us[posc].saldo := list_us[posc].saldo - valor;
      list_us[posc2].saldo := list_us[posc2].saldo + valor;
      Writeln('Transferencia realizada exitosamente.');
      Writeln('Saldo de la cuenta: ',list_us[posc].saldo:0:2,'Bs.f');
    End
  Else
    Begin
      Writeln('La cuenta seleccionad no tiene saldo alguno para ser retirado o transferido.');
      Exit;
    End;
End;
//Modulo encargado de organizar el archivo de transacciones

Procedure transacciones(ced:Integer;Var list_us:usuarios;posc:Integer);
Var
  i: Integer;
Begin
  i := 1;
  Repeat
    If (list_us[posc].movimientos[i].tipo='Transferencia')Then
      Begin
        Writeln('N°',i,' |  Tipo de transacción:',list_us[posc].movimientos[i].tipo);
        Writeln('    |  receptor:',list_us[posc].movimientos[i].receptor);
        Writeln('    |  Valor:',list_us[posc].movimientos[i].valor:0:2,
                '-------------------------------------------------');
      End
    Else
      Begin
        Writeln('N°',i,' |  Tipo de transacción:',list_us[posc].movimientos[i].tipo);
        Writeln('    |  Valor:',list_us[posc].movimientos[i].valor:0:2,
                '-------------------------------------------------');
      End;
    i := i+1;
  Until ((i=movs)Or(list_us[posc].movimientos[i].valor=0));
  Readkey;
End;
//Es el menu de opciones que se muestra despues de iniciar sesion en el programa

Procedure menu_op(ced:Integer;Var list_us:usuarios;posc:Integer);
Var
  op: Integer;
  movs: file Of list_mov;
Begin
  Assign(movs,'transacciones.txt');
  Rewrite(movs);
  Repeat
    Writeln('Bienvenido Usuario: ', list_us[posc].nombre,' ', list_us[posc].apellido,'.' );
    Writeln('Saldo: ', list_us[posc].saldo:0:2,'Bs.f' );
    Writeln('Menu de operaciones.');
    Writeln('1-. Depositar efectivo.');
    Writeln('2-. Retirar efectivo.');
    Writeln('3-. Transferir monto.');
    Writeln('4-. Ver movimientos.');
    Writeln('5-. Salir.');
    Readln(op);
    Clrscr;
    Case op Of
      1: dep(ced, list_us, posc);
      2: ret(ced, list_us,posc);
      3: trans(ced, list_us,posc);
      4: transacciones(ced, list_us,posc);
      5:
         Begin
           Writeln('Saliendo al menu principal.');
           Exit;
         End;
      Else
        Writeln('Valor inválido. Esa opción no existe.');
    End;
  Until (op=4);
End;
//modulo encargado de iniciar sesión en el cajero

Procedure inic_us(Var list_us:usuarios);
Var
  ced: Integer;
  pass: String;
  posc: Integer;
Begin
  Writeln('Porfavor introduzca su cédula:');
  Readln(ced);
  If (verif_ced(ced, list_us)=True)Then
    Begin
      posc := ob_posc(ced, list_us);
      Writeln('Usuario: ',list_us[posc].nombre,', ',list_us[posc].apellido);
      Writeln('Cédula válida, introduzca su contraseña.');
      Repeat
        Readln(pass);
        If (pass=list_us[posc].password)Then
          Begin
            menu_op(ced, list_us, posc);
            Exit;
          End
        Else
          Writeln('Contraseña incorrecta.');
      Until (pass=list_us[posc].password);
    End
  Else
    Begin
      Writeln('Cédula inválida, porfavor registrarse o introducir una cédula válida.');
      Readkey;
      Exit;
    End;
End;
//Este es el menú principal a partir del cual se utilizan las distintas funcionalidades.

Procedure menu_p(op:Integer; Var list_us:usuarios);
Var
  i,j: Integer;
Begin
  Repeat
    Clrscr;
    Writeln('---------------------------------------------------------------');
    Writeln('                     Menu principal:');
    Writeln('1-. Registrar usuario nuevo.');
    Writeln('2-. Iniciar cuenta existente.');
    Writeln('3-. Cerrar programa.');
    Readln(op);
    Case op Of
      1: reg_us(list_us);
      2: inic_us(list_us);
      3: Writeln('---------------------- Cerrando programa ----------------------');
      Else
        Writeln('Valor inválido. Presiona enter.');
      Readkey;
    End;
  Until (op=3);
End;
Begin

//------------------------------------------- Manejo de los datos de los usuarios. Crea si no existe y lee si ya existen.
  Assign(client_dat,nombre_archivo);
  If (fileexist(nombre_archivo)=True) Then
    Begin
      Reset(client_dat);
      Read(client_dat,list_us);
    End;
  init(list_us);

//------------------------------------------- Es el programa, el menu principal para registrar un usuario nuevo o iniciar una cuenta existente y manejar el dinero
  menu_p(op, list_us);

//------------------------------------------- Guarda los datos en un archivo .dat para ser utilizados la proxima vez que se abra el cajero.
  Rewrite(client_dat);
  Write(client_dat,list_us);
  Close(client_dat);
End.
