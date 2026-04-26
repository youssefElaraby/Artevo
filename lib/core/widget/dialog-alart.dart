
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';

class DialogUtils{

  static void showLoading({ required BuildContext context,required String message}){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          return
              AlertDialog(
                content: Row(
                  children: [
                    const CircularProgressIndicator(
                      color:Colors.blue,
                    ),
                    SizedBox(width: 20.w),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(message,style: TextStyle(color: AppColors.primaryColor),),
                    )
                  ],
                ),
              );
        },
    );
  }


  static void hideLoading({required BuildContext context}){
    Navigator.pop(context);
  }


  static void showMessage({required BuildContext context,
  String title='',
  required String content,
  String? postiveActionName,
  Function? postiveAction,
  String? negativeActionName,
  Function? negativeAction,
  }) {

    List<Widget> actions=[];

    //دلوقتpostiveActionName مش required
    // لو المطور استخدم البرامتر دا
    //هايروح  يعمل if condition دي
    if(postiveActionName!=null){
      //والزر الهايتعمل بعد كدا هايكون ب الاسم ال المطور يدخلو لما يستخدم البرامتر دا postiveActionName
      //يعني لو خو استدعلي البرامتر دا وحط فيها كلمه ok هنستدعي textButton ,وهايبقا اسمو ok
      actions.add(TextButton(onPressed: (){
        Navigator.pop(context);

        //postiveAction => برامتر اوبشنال مش ريكويرد
        //لو المطور استدعاء يبقا نفز if condtion دي
        //ولو اتنفزوت الحته دي هاتتنفز Navigator.pop(context);
        if(postiveAction!=null){ postiveAction.call();}

      },
          child: Text(postiveActionName))
      );
    }
    if(negativeActionName!=null){
      actions.add(TextButton(
          onPressed: (){
            if(negativeAction!=null){negativeAction.call(); }
            Navigator.pop(context);
          }, child: Text(negativeActionName))
      );
    }


    showDialog(
        context: context,
        builder: (context){
          return
              AlertDialog(
                title: Text(title,style: TextStyle(color: AppColors.primaryColor),),
                content: Text(content,style: TextStyle(color: AppColors.primaryColor),),
                //actions =>هايبقا بناء علي اخيار المطور
                //سواء بقا عايز يحط حاجه في منطقه دي ولا لا
                actions: actions,
              );
        }
    );
  }


}