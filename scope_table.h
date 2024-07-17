#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        // write your hash function here
        int sum = 0;
        for(int i = 0; i < name.size(); i++){
            sum += int(name[i]);
        }
        return (sum % bucket_count);
    }

public:
    scope_table();
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope);
    scope_table *get_parent_scope();
    int get_unique_id();
    symbol_info *lookup_in_scope(symbol_info* symbol);
    bool insert_in_scope(symbol_info* symbol);
    bool delete_from_scope(symbol_info* symbol);
    void print_scope_table(ofstream& outlog);
    ~scope_table();

    // you can add more methods if you need
    symbol_info *lookup_in_parent_scope(symbol_info* symbol);
    symbol_info *lookup_in_only_current_scope(symbol_info* symbol);
};

// complete the methods of scope_table class

scope_table::scope_table(){

}
scope_table::scope_table(int _bucket_count, int _unique_id, scope_table *_parent_scope){
    bucket_count = _bucket_count;
    unique_id = _unique_id;
    parent_scope = _parent_scope;
    table.resize(bucket_count);
}
scope_table *scope_table::get_parent_scope(){
    return parent_scope;
}

int scope_table::get_unique_id(){
    return unique_id;
}

symbol_info *scope_table::lookup_in_scope(symbol_info* symbol){
    
    //FIRST LOOKING IN THE PRESENT SCOPE
    for(int i = 0; i < table.size(); i++){
        list<symbol_info*> *info = &table[i];
        for(auto it = info->begin(); it != info->end(); it++){
            if((*it)->getname() == symbol->getname()){
                return *it;
            }
        }
    }

    //IF NOT FOUND IN THE PRESENT SCOPE THEN LOOK INTO PARENT SCOPES
    return lookup_in_parent_scope(symbol);
}

symbol_info *scope_table::lookup_in_parent_scope(symbol_info* symbol){
    //ITERATION FOR PARENT SCOPE IN CASE WE CANNOT FIND THE VALUE IN THE CURRENT SCOPE
    scope_table *sc = get_parent_scope();

    //ADDED FOR LAB4
    if(sc == NULL){
        return NULL;
    }



    
    return sc->lookup_in_scope(symbol);

}



// ADDED FOR LAB4
symbol_info *scope_table::lookup_in_only_current_scope(symbol_info* symbol){

    int hashed_index = hash_function(symbol->getname());
    list<symbol_info*> *info = &table[hashed_index];
    for(auto it = info->begin(); it != info->end(); it++){
        if((*it)->getname() == symbol->getname()){ 
            return *it;
        }
    }

    return NULL;
}



bool scope_table::insert_in_scope(symbol_info *symbol){
    int hashed_index = hash_function(symbol->getname());
    list<symbol_info *> *info = &table[hashed_index];
    info->push_back(symbol);
    // cout << "PRINTING THE SYMBOLS HERE...." << endl;
    // for(int i = 0; i < table.size(); i++){
    //     for(auto it = table[i].begin(); it!=table[i].end(); it++){
    //         cout << (*it)->getname() << endl;
    //     }
    // }
    return 0;
}

bool scope_table::delete_from_scope(symbol_info *symbol){
    int hashed_index = hash_function(symbol->getname());
    list<symbol_info *> *info = &table[hashed_index];
    info->pop_back();
}


scope_table::~scope_table(){
    for(int i = 0; i < table.size(); i++){
        table[i].clear();
    }
}

void scope_table::print_scope_table(ofstream& outlog)
{
    outlog << "ScopeTable # "+ to_string(unique_id) << endl;

    //iterate through the current scope table and print the symbols and all relevant information
    for (int i = 0; i < table.size(); i++){
        
        for (auto it = table[i].begin(); it != table[i].end(); it++){
            outlog<< i << " -->"<<endl;
            outlog << "< " << (*it)->getname() << " : " << (*it)->get_type() << " >\n";
            if((*it)->getVariableState()) {
                outlog << "Variable\n";
                outlog << "Type: " << (*it)->get_returnType() << endl;
            }
            else if((*it)->getFunctionState()) {
                outlog << "Function Definition\n"; 
                outlog << "Return Type: " << (*it)->get_returnType() << endl;

                outlog << "Number of Parameters: " << (*it)->getParameterSize() << endl;
                outlog << "Parameter Details: ";

                int numberOfParameters = (*it)->getParameterSize();
                if(numberOfParameters > 0){
                    list<symbol_info*> parameter_info = (*it)->getParameterInfo();
                    for(auto it2 = parameter_info.begin(); it2!=parameter_info.end(); it2++){
                        outlog << (*it2)->getname() << " " << (*it2)->get_returnType();
                        if(numberOfParameters>1){
                            numberOfParameters--;
                            outlog << ", ";
                        }
                    }
                    
                }
                outlog << "\n";
            }
            else if((*it)->getArrayState()) {
                outlog << "Array\n"; 
                outlog << "Type: " << (*it)->get_returnType() << endl;
                outlog << "Size: " << (*it)->get_arraySize() << endl;
            }
            outlog << endl;
           
        }
    }

    

}