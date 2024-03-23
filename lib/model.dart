class ObjectPrintResult {
  final PrintResult result;
  final String message;
  final int value;

  ObjectPrintResult(this.result, this.message, this.value);
}

enum PrintResult {
  readyForPrint,
  noPaper,
  hotPrinter,
  hotPrinterOrNoPaper,
  timeout,
  unknownError,
  successPrint
}

PrintResult getResultPrintFromCode(int code) {
  switch (code) {
    case 0:
      return PrintResult.readyForPrint;
    case 1:
      return PrintResult.noPaper;
    case 2:
      return PrintResult.hotPrinter;
    case 3:
      return PrintResult.hotPrinterOrNoPaper;
    case 4:
      return PrintResult.timeout;
    case 5:
      return PrintResult.unknownError;
    case 6:
      return PrintResult.successPrint;
    default:
      return PrintResult.unknownError;
  }
}
