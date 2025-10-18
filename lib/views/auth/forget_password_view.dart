import 'package:chat/controllers/forget_password_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: controller.formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      onPressed: controller.gobacktologin,
                      icon: Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Forget password ",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Text(
                    "enter your email to receve a password reset link",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textsecondrycolor,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primecolor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 55,
                      color: AppTheme.primecolor,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Obx(() {
                  if (controller.emailsend) {
                    return _buildemailsendcontent(controller);
                  } else {
                    return _buildemailform(controller);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildemailform(ForgetPasswordController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailcontroller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email Address",
            prefixIcon: Icon(Icons.email_outlined),
            hintText: "enter your email address",
          ),
          validator: controller.validareemail,
        ),
        SizedBox(height: 32),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  controller.isloading ? null : controller.sendpasswordreset,

              icon:
                  controller.isloading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(Icons.send),
              label: Text(
                controller.isloading ? 'sending...' : 'send reset link',
              ),
            ),
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Rememper your password",
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: controller.gobacktologin,
              child: Text(
                "Sign in",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primecolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildemailsendcontent(ForgetPasswordController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.succescolor.withOpacity(.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.succescolor.withOpacity(.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                size: 60,
                color: AppTheme.succescolor,
              ),
              SizedBox(height: 16),
              Text(
                "Email sent!",
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.succescolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We have send a password reset link to:",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textsecondrycolor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                controller.emailcontroller.text,
                style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primecolor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "check your email and follow the instruchions to reset the password ",
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textsecondrycolor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.resentemail,
            icon: Icon(Icons.refresh),
            label: Text("Resent email"),
          ),
        ),
        SizedBox(height: 16,),
SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.gobacktologin,
            icon: Icon(Icons.arrow_back),
            label: Text("Back to sign in"),
          ),
        ),
        SizedBox(height: 24,),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondrycolor.withOpacity(.1),
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
              size: 20,
              color: AppTheme.secondrycolor,),
              SizedBox(width: 12,),
              Expanded(child: Text(
                 "Didnt receive the email? Check tour span or try again",
                 style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondrycolor
                 ),
              ))
            ],
          ),
        )
      ],
    );
  }
}
