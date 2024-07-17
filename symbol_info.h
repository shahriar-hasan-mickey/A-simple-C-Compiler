#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;
    

    // Write necessary attributes to store what type of symbol it is (variable/array/function)
    bool isVariable = false;
    bool isFunction = false;
    bool isArray = false;
    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...)
    //string type;
    string returnType;
    // Write necessary attributes to store the parameters of a function
    list<symbol_info*> parameter_info;
    int parameter_size;
    // Write necessary attributes to store the array size if the symbol is an array
    int arraySize;

public:
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;
    }
    string getname()
    {
        return name;
    }
    string get_type()
    {
        return type;
    }
    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }
    
    // Write necessary functions to set and get the attributes

    void set_returnType(string returnType){
        this->returnType = returnType;
    }

    string get_returnType(){
        return returnType;
    }

    void set_arraySize(int arraySize){
        this->arraySize = arraySize;
    }

    int get_arraySize(){
        return arraySize;
    }

    void setVariableState(bool state){
        this->isVariable = state;
    }

    
    bool getVariableState(){
        return isVariable;
    }

    void setFunctionState(bool state){
        this->isFunction = state;
    }

    bool getFunctionState(){
        return isFunction;
    }
    
    void setArrayState(bool state){
        this->isArray = state;
    }

    bool getArrayState(){
        return isArray;
    }

    void setParameterInfo(list<symbol_info*> parameter_info){
        this->parameter_info = parameter_info;
    }
    list<symbol_info*> getParameterInfo(){
        return parameter_info;
    }

    void setParameterSize(int size){
        this->parameter_size = size;
    }

    int getParameterSize(){
        return parameter_size;
    }

    ~symbol_info()
    {
        // Write necessary code to deallocate memory, if necessary
    }
};