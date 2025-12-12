class AccountCardModel{
  final String _accountType,_accountNumber,_accountBalance,_others, _accountStatus;
  AccountCardModel(
      this._accountType,
      this._accountNumber,
      this._accountBalance,
      this._others,
      this._accountStatus
      );

  String get accountNo
  {
    var letters=[];
    for(int i=0;i<_accountNumber.length;)
    {
      letters.add(_accountNumber.substring(i,( ( i ~/4)+1)*4));
      i+=4;
    }
    var fakeAccountNo="";
    for(int i=0;i<letters.length;i++)
    {
      if(i==letters.length-1)
      {
        fakeAccountNo+=letters[i];
        break;
      }
      fakeAccountNo+="****    ";
    }
    return fakeAccountNo;
  }

  String get accountType => _accountType;
  String get accountNumber => _accountNumber;
  String get accountBalance => _accountBalance;
  String get others => _others;
  String get accountStatus => _accountStatus;

}