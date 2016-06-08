#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>



char token_buffer[33];
FILE *original;
FILE *salida;
FILE * tmp ;
int in_char,c;
int raro=0;
int continuar=0;

int espace = 0;

//Se definen los diferentes tipos a tratar
typedef enum tipos_palabras{
	//ANYWORD ES IGUAL A CUALQUIER VALOR.
	INCLUDE,DEFINE,FIN, ANYWORD, PUNTUACTION,ESPACIO,COMMENT, NOT_COMMENT,BIG_COMMENT
} palabras;


//Variable para saber el temporal
int cont=0;

//Define el tamanno de los vectores nombre,valor
int _totalDefine =0;
int _totalIncludeUsuario=0;
int _totalInclude=0;
//Variable de control
int estado=0;

void clear_buffer(void){
	//Borra el buffer de token buffer.
	memset(token_buffer,'\0',strlen(token_buffer));
}

void buffer_char(int _val){
	//Convierte el entero a caracter y lo agrega al token_buffer
	if (strlen(token_buffer)==0){
		char dato=(char)_val;
		char auxiliar[]={(char)_val,'\0'};
		strcat(token_buffer,auxiliar);
	}
	else{
		char dato=(char)_val;
		char auxiliar[]={dato,'\0'};
		strcat(token_buffer,auxiliar);
	}
}

palabras reservado(){
	//Revise el token_buffer y si este es una palabra reservada retorna el token al que pertenece

	if (strcmp(token_buffer,"#define")==0){
		raro=1;
		return DEFINE;
	}
	if (strcmp(token_buffer,"#include")==0){
		return INCLUDE;
	}
	else{
		return ANYWORD;
	}
}

void imprimir_espacios(){
	if (c==10){
		fprintf(tmp,"\n");
		}
	if (c==32){
		fprintf(tmp,"  ");
		}
}

palabras escaner(FILE * archivo){
	//Obtiene los tokens del texto


	clear_buffer();
	if (feof(archivo))
		return FIN;

	while (feof(archivo)==0){
		//Leemos del archivo
		in_char=fgetc(archivo);

		//Si el token es espacio lo ignoro
		if (isspace(in_char)){
			c=in_char;
			return ESPACIO;
		}

		if (in_char==47){
			in_char = fgetc(archivo);
			if (in_char==47){


			return COMMENT;
		}
			if (in_char=='*'){
				c=in_char;
				return BIG_COMMENT;
			}
			else{
				c=in_char;
				return NOT_COMMENT;
			}
		}

		//Si el token es un digito,minuscula,mayuscula o de puntuacion se agregan al buffer_char para imprimirlos
		else if (in_char==35){
			buffer_char(in_char);
			c=fgetc(archivo);
			while (c==32){
				c=fgetc(archivo);
			}
			buffer_char(c);
			for (c=fgetc(archivo);isalnum(c)||isspace(c)||isgraph(c);c=fgetc(archivo)){

					if (isspace(c)){
						return reservado();
					}
					
					buffer_char(c);
			}

		}
		else if (isgraph(in_char)){
			
			if (in_char >= 33 && in_char <=47 || in_char >= 58 && in_char <=64 || in_char >= 91 && in_char <=96 || in_char >= 123 && in_char <=126 ){
				c = in_char;
				return PUNTUACTION;
			}
			else{
				buffer_char(in_char);
			}


			for (c= fgetc(archivo);isalnum(c)||isspace(c)||isgraph(c);c=fgetc(archivo)){
				if (isspace(c)){
					return reservado();
				}

				if (c >= 33 && c <=47 || c >= 58 && c <=64 || c >= 91 && c <=96 || c >= 123 && c <=126 ){
				   //buffer_char(c);
				   return PUNTUACTION;
			}
				buffer_char(c);

				}
				return reservado();
			}




		}

	}


int posicion(char ** arreglo){
	int pos = cont;
	int i=0;
	for (i<cont;i++;){
		if (strcmp(arreglo[i],token_buffer)==0){
			pos=i;
		}
		
	}
	return pos;
}

void asignar_nombre(char * nombre,FILE * archivo){
	//Almacena el nombre de la variable definida por el #define

	strcpy(nombre,token_buffer);
}

void asignar_valor(char * valor,FILE * archivo){
	//Almacena el valor de la variable definida por el #define
	memset(valor, '\0', sizeof(valor));
	int no =0;
	palabras palabras=escaner(archivo);
	while (palabras==ESPACIO){
		palabras=escaner(archivo);
	}
	while (palabras==ANYWORD || palabras == PUNTUACTION){

	if (palabras==PUNTUACTION){
		if (strlen(token_buffer)==0){
			buffer_char(c);
			strcat(valor,token_buffer);
		}
		else{
			strcat(valor,token_buffer);
			clear_buffer();
			buffer_char(c);
			strcat(valor,token_buffer);
		}
	}

	if (palabras==ANYWORD)
	{
		strcat(valor,token_buffer);
	}
	if (isspace(c)){
		palabras=ESPACIO;
	}
	else{

	palabras=escaner(archivo);
	}
}
}

void adjuntar(char * valor){

	char aux[33];
	strcpy(aux,token_buffer);

	
	strcat(valor,aux);
	strcat(valor,"\0");

}

void eliminar_comentarios(FILE * archivo){
	palabras palabras=escaner(archivo);
	int continuar=0;
	while (continuar==0){
		if (c==10){
			continuar=1;
		}
		else{
			palabras=escaner(archivo);
		}
	}
}

void eliminar_comentarios_grandes(FILE * archivo){
	palabras palabras=escaner(archivo);

	while (continuar==0){
		if (c=='*'){
			
			palabras=escaner(archivo);
			if (c==47 || palabras==NOT_COMMENT){
			printf("%s\n","hola" );
			continuar=1;
		}
	}
		
		if (continuar==0){
			palabras=escaner(archivo);
		}
		
	}	
}




void incluir_include(FILE * archivo){
	//Se encarga de leer el archivo de nuevo y asignar los valores almacenados segun el #define

	char fichero[33];
	memset(fichero, '\0', sizeof(fichero));
	int not_define=0;
	palabras palabras = escaner(archivo);
	int _estaDefinido=0;
	int signo_puntuacion = 0;

	while (palabras!=FIN){
		memset(fichero, '\0', sizeof(fichero));
		switch(palabras){
			case BIG_COMMENT:
				continuar=0;
				eliminar_comentarios_grandes(archivo);
				break;
			case DEFINE:
				if (raro==1){
				asignar_valor(fichero,archivo);
				
				fprintf(tmp,"#define %s ",fichero);


				asignar_valor(fichero,archivo);
				
				fprintf(tmp,"  %s \n",fichero);
				raro=0;
			}
				break;
			case INCLUDE:
						
				palabras = escaner(archivo);
				int continuar =0;
				if (c==34){
					
					palabras=escaner(archivo);
					while (continuar==0){


						adjuntar(fichero);
						if (c==46){
							clear_buffer();
							buffer_char(c);
							adjuntar(fichero);
						}
						palabras=escaner(archivo);
						if (c==34){
							adjuntar(fichero);
							continuar=1;
						}
						
						
					}
					
					FILE * x = fopen(fichero,"r+");

					incluir_include (x);
					break;


				}
					if (c==60){
					while (continuar==0){
						adjuntar(fichero);
						if (c==46){
							clear_buffer();
							buffer_char(c);
							adjuntar(fichero);
						}
						palabras=escaner(archivo);
						if (c==62){
							adjuntar(fichero);
							continuar=1;
						}

						

						
					}
					//fprintf(tmp,"#include <%s> \n",fichero);
				}
				break;
				
			case ANYWORD:
					fprintf(tmp,"%s",token_buffer);
					imprimir_espacios();
					break;
					
				break;
			case PUNTUACTION:
				signo_puntuacion=0;
				if (strlen(token_buffer)==0){
					buffer_char(c);
					fprintf(tmp,"%s",token_buffer);
					break;
				}
				else{
					_estaDefinido = 0;
		
				//Si no esta definido solo imprimo
				if (_estaDefinido == 0){
					fprintf(tmp,"%s",token_buffer);
					
				
					clear_buffer();
					buffer_char(c);
					fprintf(tmp,"%s", token_buffer);
					break;

				}

			case ESPACIO:
				imprimir_espacios();

				default:
					break;

		}
			case COMMENT:
				eliminar_comentarios(archivo);
				break;
			case NOT_COMMENT:
				
				clear_buffer();
				buffer_char(c);
				fprintf(tmp,"%s","/");
				break;


		imprimir_espacios();
			
				
}
		
				
		palabras=escaner(archivo);
	
}


}

void contador (FILE * archivo){
	rewind(archivo);
	palabras palabras = escaner(archivo);
	while (palabras!=FIN){
		switch(palabras){
		case DEFINE:
			if (raro==1){
			_totalDefine ++;
			raro=0;
			}
			break;
		

	}
	palabras=escaner(archivo);   
}
}


void reconocedor(FILE * archivo,FILE * tmp){
	//Se encarga de obtener los nombres y valores definidos por el #define
	rewind(archivo);
	int _estaDefinido=0;
	char guardar[33];
	char guardar2[33];
	char *nombre[_totalDefine];
	char *valor[_totalDefine];
	int pos; 
	palabras palabras = escaner(archivo);
	int esta=0;

	while (palabras!=FIN){
	
		switch(palabras){
			case NOT_COMMENT:
				clear_buffer();
				buffer_char(c);
				fprintf(tmp,"/%s",token_buffer);
				break;
						

			case DEFINE:
				//No se pasa con el & debido a que la estructura ya es *guardar
				if (raro==1){
				memset(guardar2, '\0', sizeof(guardar2));
				escaner(archivo);
				pos= posicion(nombre);
				asignar_nombre(guardar,archivo);
				nombre[pos]=strdup(guardar);
				
				asignar_valor(guardar2,archivo);
				valor[pos]=strdup(guardar2);

				if (pos==cont){
					cont ++;
				}
				raro=0;
			}
			break;
	case ANYWORD:
				esta =0;
				int i=0;
				for (i<cont;i++;){
					if (strcmp(nombre[i],token_buffer)==0){
						fprintf(tmp, "%s",valor [i]);
						esta=1;
					}
				}
				if (esta==0){
					fprintf(tmp, "%s", token_buffer);
				}
				break;
					
			case PUNTUACTION:
				//signo_puntuacion=0;
			
				if (strlen(token_buffer)==0){
					buffer_char(c);
					fprintf(tmp,"%s",token_buffer);
					break;
				}
				else{
					_estaDefinido = 0;
		
				//Si no esta definido solo imprimo
				if (_estaDefinido == 0){
					fprintf(tmp,"%s",token_buffer);
					
				
					clear_buffer();
					buffer_char(c);
					fprintf(tmp,"%s", token_buffer);
					break;

				}
				break;
			}
	

			case ESPACIO:
				imprimir_espacios();
				break;
				default:
					break;
			
		
	}

	palabras = escaner(archivo);
	
	//Llamamos a cambiador para reescribir el texto por su respectivo valorr
}}











int main(int argc, char const *argv[])
{
	char parser[100];
	original=fopen(argv[1],"r+");
	tmp = fopen ("tmp.c","w+");

	incluir_include(original);
	contador(tmp);
	fclose(original);
	fclose(tmp);
	original=(fopen("tmp.c","r+"));
	tmp = fopen("listo.c","w+");

	reconocedor(original,tmp);
	remove("tmp.c");
	
	snprintf(parser, sizeof(parser), "./parser listo.c %s",argv[2]);
	system(parser);
	return 0;
}









