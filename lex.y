%option noyywrap yylineno nodefault noinput nounput
%{
    #include <stdlib.h>
    #include <stdio.h>
	enum yyokentype {  
        SNIP  = 99,      
        BODY  = 98,      
    };
    union YYSTYPE {
        char* str;    
    };
    union YYSTYPE yylval;
    int fileno(FILE *stream);
%}

%%

^#\ .*        { /* ignore */ }
^snippet\ .*  { yylval.str = yytext+8; return SNIP; }
\t.*          { yylval.str = yytext+1; return BODY; }
[ ]{4}.*      { yylval.str = yytext+4; return BODY; }
.|\n          { /* ignore */ }

%%

  /*! 
   *  verify ""  after snippet name, add to description
   *  add default description
   */


char* visual = "VISUAL";
char* vim    = "${VIM:";
char* replace = "TM_SELECTED_TEXT";

void print_tab(int);

char* filter(char*);
char* get_name(char*);
char* get_description(char*);

int main() {
    /* yyin = fopen("./c.snippets", "r"); */ 
    int token_type;
    int snip_count = 0;
    int body_count = 0;
    char* line;
    printf("{\n");
    do {
        token_type = yylex();
        switch (token_type) {
            case SNIP:
                if (snip_count != 0)
                {
                    printf("\n");
                    print_tab(2);
                    printf("]\n");       
                    print_tab(1);
                    printf("},\n");       
                }
		char* name = get_name(yylval.str);
		char* description = get_description(yylval.str);
                print_tab(1);
                printf("\"%s\": {\n", name);
                print_tab(2);
                printf("\"prefix\": \"%s\",\n", name);
                print_tab(2);
                printf("\"description\": \"%s\",\n", description);
                print_tab(2);
                printf("\"body\": [\n");
                body_count = 0;
                snip_count++;
		free(name);
		free(description);
                break;
            case BODY:
                if (body_count != 0)
                {
                    printf(",\n");
                }
                line = filter(yylval.str);
                print_tab(2);
                printf("\"%s\"", line);
                body_count++;
                free(line);
                break;
            default:
                break;
        }
    } while(token_type != 0);  // if yylex returned 0 we reached EOF

    print_tab(2);
    printf("]\n");       
    print_tab(1);
    printf("}\n");       
    printf("}\n");       


}

void print_tab(int n)
{
    for (int i = 0; i < n; i++)
        printf("    ");
}


char* filter(char* str)
{
   int script_start = 0; 
   int len = strlen(str); 
   char* filtered = malloc(10*(1 + len) * sizeof(char));


   char* pos = filtered;
   while (*str != '\0')
   {
        if(strstr(str, visual) == str)
        {
            strcpy(pos, replace);
            pos += 16;
            str += 6;
        }


        switch(*str)
        {
            case '\t':
                *pos++ = ' ';
                *pos++ = ' ';
                *pos++ = ' ';
                *pos = ' ';
                break;
            case '"':
                *pos++ = '\\';
                *pos = '"';
                break;
            case '\\':
                *pos++ = '\\';
                *pos = '\\';
                break;
            case '`':
                if(script_start == 0) {
                    strcpy(pos, vim);
                    pos += 5;
                    script_start = 1;
                } else {
                    *pos = '}';
                    script_start = 0;
                }
                break;
            default:
                *pos = *str;
                break;
        }
        str++;
        pos++;
   }
   *pos = '\0';
   return filtered;
}

char* get_name(char* str)
{
	char* name = malloc(1+strlen(str)*sizeof(char));
	char* pos = name;
	while(*str != '\0' && *str != ' ' && *str != '\t')
		*pos++ = *str++;	
	*pos = '\0';
	return name;
}

char* get_description(char* str)
{
	char* description = malloc(1+strlen(str)*sizeof(char));
	strcpy(description, str);
	 while(*str != '\0' && *str != '"')
	 	str++;	
	 if(*str == '"') {
	 	char* pos = description;
	 	str++;
	 	while(*str != '\0' && *str != '"')
	 		*pos++ = *str++;	
	 	*pos = '\0';
	 } 
	return description;
}
