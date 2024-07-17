%{
#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin; // yyin is the pointer for the file input
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
symbol_table SymbolTable(10);
// You can store the pointer to your symbol table in a global variable
symbol_table *sTable;// = new symbol_table(10);


symbol_info *info;



// or you can create an object

int lines = 1;

ofstream outlog;
ofstream errorlog;

// you may declare other necessary variables here to store necessary info
// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.
list<symbol_info*> parameter_info;
symbol_info *function_info;
list<symbol_info*> s;



void yyerror(char *s){
    outlog << "At line" << lines << " " << s << endl << endl;
	 // you may need to reinitialize variables if you find an error
}


%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print your whole symbol table here
		//cout << "printing all scopes here\n";
		sTable->print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN {
						//cout << $1->getname()+"PRINTING THIS.....\n";
						function_info = new symbol_info($2->getname(), $2->get_type());
						function_info->setFunctionState(true);
						function_info->set_returnType($1->getname());
						//cout << "[PARAMETER SIZE..]\n";
						//cout <<  parameter_info.size() << endl;
						function_info->setParameterSize(parameter_info.size());
						function_info->setParameterInfo(parameter_info);
						
						cout << "[INSERTING SYMBOL..]\n";
						



						//ADDED FOR LAB4
						int returnedResult = sTable->insert(function_info);
						if(returnedResult == 0){
							errorlog << "At line no: " << lines << " Multiple declaration of function " << function_info->getname() << endl << endl ;
						}


						
						//cout << "Entering new scope..\n";
						sTable->enter_scope(outlog);
						for(auto it=parameter_info.begin(); it!=parameter_info.end(); it++){
							
							//ADDED FOR LAB4
							int returnedResult = sTable->insert((*it));
							if(returnedResult == 0){
								errorlog << "At line no: " << lines << " Multiple declaration of variable " << (*it)->getname() << " in parameter of "<< function_info->getname() << endl << endl ;
							}

						}


						parameter_info.clear(); // THIS COULD ALSO HAVE BEEN DONE ON THE COMPOUND STATEMENT'S GRAMMAR PORTION
					} compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"("+$4->getname()+")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$4->getname()+")\n"+$7->getname(),"func_def");	
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
			
			
			//sTable->insert(function_info);
			
            // However, note that the scope of the function and the scope of the compound statement are different.
		}
		| type_specifier ID LPAREN RPAREN {
						//cout << $1->getname()+"PRINTING THIS.....\n";
						function_info = new symbol_info($2->getname(), $2->get_type());
						function_info->setFunctionState(true);
						function_info->set_returnType($1->getname());
						// cout << "[PARAMETER SIZE..]\n";
						// cout <<  parameter_info.size() << endl;
						function_info->setParameterSize(0);
						
						
						cout << "[INSERTING SYMBOL..]\n";
						//ADDED FOR LAB4
						int returnedResult = sTable->insert(function_info);
						if(returnedResult == 0){
							errorlog << "At line no: " << lines << " Multiple declaration of function " << function_info->getname() << endl << endl ;
						}

						//cout << "Entering new scope..\n";
						sTable->enter_scope(outlog);
					} compound_statement
		{
			
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$6->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$6->getname(),"func_def");	
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
			
			
			
			
			//sTable->insert(function_info);


            // However, note that the scope of the function and the scope of the compound statement are different.
		}
 		;





parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;
					
			$$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");
			
            // store the necessary information about the function parameters

			info = new symbol_info($4->getname(), $4->get_type());
			info->set_returnType($3->getname());
			info->setVariableState(true);
			
			
			
			
			
			parameter_info.push_back(info);

            // They will be needed when you want to enter the function into the symbol table
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
			
            // store the necessary information about the function parameters


/*
			info = new symbol_info($3->getname(), $3->getname());
			info->setVariableState(true);
			sTable->insert(info);
*/


            // They will be needed when you want to enter the function into the symbol table
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");
			
            // store the necessary information about the function parameters


			
			info = new symbol_info($2->getname(), $2->get_type());
			info->setVariableState(true);
			info->set_returnType($1->getname());
			
			
			//sTable->insert(info);
			
			
			parameter_info.push_back(info);
			

            // They will be needed when you want to enter the function into the symbol table
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"param_list");
			
            // store the necessary information about the function parameters

/*
			info = new symbol_info($3->getname(), $3->getname());
			info->setVariableState(true);
			sTable->insert(info);
*/



            // They will be needed when you want to enter the function into the symbol table
		}
 		;

compound_statement : LCURL statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$2->getname()+"\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n"+$2->getname()+"\n}","comp_stmnt");
				//cout << $2->getname() << endl << endl;
                // The compound statement is complete.
                // Print the symbol table here and exit the scope
				
				

				sTable->print_all_scopes(outlog);
				//cout << "[PRINTING SYMBOL TABLE..]\n";
				sTable->exit_scope(outlog);
				s.clear();
                // Note that function parameters should be in the current scope
 		    }
 		    | LCURL RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");
				
				// The compound statement is complete.
                // Print the symbol table here and exit the scope
				
				sTable->print_all_scopes(outlog);
				sTable->exit_scope(outlog);
				
				//cout << "[PRINTING SYMBOL TABLE..]\n";
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_dec");
			
			// Insert necessary information about the variables in the symbol table



			for(auto it = s.begin(); it!=s.end(); it++){
				(*it)->set_returnType($1->getname());


			    //ADDED FOR LAB4
				int returnedResult = sTable->insert(*it);
				if(returnedResult == 0){
					errorlog << "At line no: " << lines << " Multiple declaration of variable " << (*it)->getname() << endl << endl ;
				}

				
				if((*it)->get_returnType() == "void"){
					errorlog << "At line no: " << lines << " variable type can not be void " << endl << endl ;
				}


			}
			s.clear();
		 }
 		 ;

type_specifier : INT
		{

			
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname()+","+$3->getname(), "declaration_list");

            // you may need to store the variable names to insert them in symbol table here or later
			info = new symbol_info($3->getname(), $3->get_type());
			info->setVariableState(true);
			s.push_back(info);
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;
			$$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]", "declaration_list");


            // you may need to store the variable names to insert them in symbol table here or later
			info = new symbol_info($3->getname(), $3->get_type());
			info->setArrayState(true);
			info->set_arraySize(stoi($5->getname()));
			s.push_back(info);
 		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			$$ = new symbol_info($1->getname(), "declaration_list");

            // you may need to store the variable names to insert them in symbol table here or later
			info = new symbol_info($1->getname(), $1->get_type());
			info->setVariableState(true);
			s.push_back(info);
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD //array
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
			$$ = new symbol_info($1->getname()+"["+$3->getname()+"]", "declaration_list");

            // you may need to store the variable names to insert them in symbol table here or later
            info = new symbol_info($1->getname(), $1->get_type());
			info->setArrayState(true);
			info->set_arraySize(stoi($3->getname()));
			s.push_back(info);
 		  }
 		  ;
 		  

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
	   }
	   ;
	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  // ENTERTING A NEW SCOPE HERE FOR ANY TYPES OF NEW BLOCK
	  | {sTable->enter_scope(outlog);} compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($2->getname(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->getname()<<");"<<endl<<endl; 
			
			$$ = new symbol_info("printf("+$3->getname()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->getname()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->getname()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"varbl");





		info = new symbol_info($1->getname(), $1->get_type());
		info = sTable->lookup(info);
		outlog << info  << "" << info->getname() << endl << endl;
		if(info == NULL){
			errorlog << "At line no: " << lines << " Undeclared variable " << $1->getname() << endl << endl ;
		}else{
			$$->set_returnType(info->get_returnType());
		}
		



		
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","varbl");

		if($3->get_returnType() != "int"){
			errorlog << "At line no: " << lines << " array index is not of integer type : " << $1->getname() << endl << endl ;
		}
	 }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"expr");

			$$->set_returnType($1->get_returnType());
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"lgc_expr");

			$$->set_returnType($1->get_returnType());
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"lgc_expr");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"rel_expr");

			$$->set_returnType($1->get_returnType());
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel_expr");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"simp_expr");

			$$->set_returnType($1->get_returnType());
			
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simp_expr");
	      }
		  ;
					
term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"term");
			$$->set_returnType($1->get_returnType());
			
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"term");
			
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname(),"un_expr");
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2->getname(),"un_expr");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"un_expr");
			$$->set_returnType($1->get_returnType());
	     }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
		$$->set_returnType($1->get_returnType());
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;

		$$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");

		info = new symbol_info($1->getname(), $1->get_type());
		info = sTable->lookup(info);
		// for(auto it=parameter_info.begin(); it!=parameter_info.end(); it++){
							
		// 					//ADDED FOR LAB4
		// 					int returnedResult = sTable->insert((*it));
		// 					if(returnedResult == 0){
		// 						errorlog << "At line no: " << lines << " Multiple declaration of variable " << (*it)->getname() << " in parameter of "<< function_info->getname() << endl << endl ;
		// 					}

		// 				}
		int iterator = 1;
		list<symbol_info*> parameter_info2 = info->getParameterInfo();
		cout << "=====>>>>" << $1->getname() << endl << endl;
		for(auto it=parameter_info.begin(), it2=parameter_info2.begin(); it!=parameter_info.end() && it2!=parameter_info2.end(); it++, it2++){
			cout << (*it)->getVariableState() + " ---------------- " + (*it2)->getVariableState()<<endl<<endl;
			if((*it)->getArrayState() && !(*it2)->getVariableState()){
				errorlog << "At line no: " << lines << " variable is of array type : " << $1->getname() << endl << endl ;
			}
			else if((*it)->get_returnType() != (*it2)->get_returnType()){
				cout << (*it)->get_returnType() << " " <<  (*it2)->get_returnType() << endl << endl;
				errorlog << "At line no: " << lines << " argument " << iterator << " type mismatch in function call: " << $1->getname() << endl << endl ;
			}
			iterator++;
		}

		parameter_info.clear();
		parameter_info2.clear();

	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->getname()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->getname()+")","fctr");
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");

		$$->set_returnType("int");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");

		$$->set_returnType("float");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->getname()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"++","fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->getname()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"--","fctr");
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->getname()<<endl<<endl;
						
					$$ = new symbol_info($1->getname(),"arg_list");

					$$->set_returnType($1->get_returnType());
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname()+","+$3->getname(),"arg");
				info = new symbol_info($3->getname(), $3->get_type());
				info->set_returnType($1->get_returnType());
				parameter_info.push_back(info);
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname(),"arg");
				info = new symbol_info($1->getname(), $1->get_type());
				info->set_returnType($1->get_returnType());
				parameter_info.push_back(info);

		  }
	      ;
 

%%

int main(int argc, char *argv[]){
    if(argc != 2){
        //cout << "Please input file name" << endl;
        return 0;
    }

    yyin = fopen(argv[1], "r");
    outlog.open("21141013_log.txt", ios::trunc);
	errorlog.open("21141013_error.txt", ios::trunc);



    if(yyin == NULL){
        //cout << "Could not open the file" << endl;
        return 0;
    }

	sTable = &SymbolTable;
	sTable->enter_scope(outlog);
	//cout << "\nGlobal Scope Entered..\n";

    yyparse();

    outlog << endl << "Total lines: " << lines << endl;

    outlog.close();
	errorlog.close();

    fclose(yyin);

    return 0;

}


