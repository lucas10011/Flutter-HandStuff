import 'dart:io';
import 'dart:typed_data';


import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

class ConvertPdf{
static convert(List<Map> listString) async {
  
  ByteData otherfont = await rootBundle.load('assets/fonts/Roboto-Light.ttf').catchError((error) {
      print(error);
  });
  final ttf = Font.ttf(otherfont);

  final Document pdf = Document();

  List<String> formatacao = <String>['Header1','Header2','Paragraph','Column',];

  mountPdf(Context context){
    print(listString[0]);  
    List<Widget> bodyPdf = <Widget>[];
    List<Widget> customWidgets = <Widget>[];
      for (var i = 0; i < listString.length; i++){

          switch (listString[i]['type']) {
              case 0:
                customWidgets.add(Header(level: 1,text:listString[i]['stringPdf'],textStyle:TextStyle(font: ttf,fontSize: 25)));
                break;
              case 1: 
                 customWidgets.add(Header(level: 2,text:listString[i]['stringPdf'],textStyle:TextStyle(font: ttf,fontSize: 20)));
                break;
              case 2:
                  customWidgets.add(Paragraph(text:listString[i]['stringPdf'],textAlign: TextAlign.left,style: TextStyle(font: ttf)));
                break;
              case 3:
               customWidgets.add(Column(crossAxisAlignment: CrossAxisAlignment.center,children: <Widget>[
                  Bullet(text:listString[i]['stringPdf'],style: TextStyle(font: ttf)),
                  ]));     
                break;
            }
          }
      
        bodyPdf.add(Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('MyMatter Portable Document Format', textScaleFactor: 2),
                      PdfLogo()
                    ])));

        customWidgets.forEach((item) => bodyPdf.add(item));    


          bodyPdf.add(Padding(padding: const EdgeInsets.all(10)));

          bodyPdf.add(Paragraph(text:'Text is available under the Creative Commons Attribution Share Alike License.'));
          print('$bodyPdf');
          return bodyPdf;
  }
  pdf.addPage(MultiPage(
      pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: Text('Portable Document Format',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => mountPdf(context)));
  final output = await getExternalStorageDirectory();
  String nametemp = DateTime.now().millisecondsSinceEpoch.toString();
  final file = File("${output.path}/$nametemp.pdf");
  file.writeAsBytesSync(pdf.save());
  return "${output.path}/$nametemp.pdf";
  }
}