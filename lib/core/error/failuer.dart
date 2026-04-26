abstract class Failures{
  String errorMessage;
  Failures( this.errorMessage);
}
class ServerError extends Failures{
  ServerError(super.errorMessage);
}
class NetworkError extends Failures{
  NetworkError( super.errorMessage);
}
