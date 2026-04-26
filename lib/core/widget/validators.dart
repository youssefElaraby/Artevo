class AppValidators{
AppValidators._();

static String? validateEmail(String? val){
  RegExp emailRegex =RegExp(r"^[a-zA-Z-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+");
  if(val==null){
    return'this field is required';
  }else if(val.trim().isEmpty){
    return'this field is required';
  }else if (emailRegex.hasMatch(val)==false){
    return 'enter vaild email';
  }else{
    return null;
  }
}
static String? validatePassword(String? val){
  RegExp passwordRegExp=RegExp(r'^(?=.*[a-zA])(?=.*[0-9])');
  if(val==null){
    return'this field is required';
  }else if(val.trim().isEmpty){
    return'this field is required';
  }else if(val.length<8||!passwordRegExp.hasMatch(val)){
    return'Strong Password Please';
  }else{
    return null;
  }
}

static String?validateConfiromPassword(String? val,String password){
  if(val==null||val.isEmpty){
    return'this faild is required';
  }else if(val!=password){
    return'same password';
  }else{
    return null;
  }


}

static String? validateUsername(String? val) {
  RegExp usernameRegex=RegExp(r'[a-zA-Z0-9,.-]+$');
  if(val==null||val.isEmpty){
    return'this faild is required';
  }else if(!usernameRegex.hasMatch(val)){
    return'enter valid username';
  }else{
    return null;
  }
}
static String?validateFullName(String?val){
  if(val==null||val.isEmpty){
    return'this faild is required';
  }else {
    return null;
  }
}

static String? validatePhoneNumber(String? val){
  if(val==null||val.isEmpty) {
    return 'this faild is required';
  }else if(int.tryParse(val.trim())==null){
  return'enter numbers only';
  }else if(val.trim().length !=11){
  return'enter value must equal 11 digit';
  }
  else {
    return null;
  }
}

}