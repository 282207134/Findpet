import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class WelcomeFlow extends StatefulWidget {
  const WelcomeFlow({super.key});
  @override
  State<WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<WelcomeFlow> {
  int step = -1;
  static const titles = [
    'Find the Pet you love\naround you easily',
    'Sell Your Pet on your\nsmartphone.',
    'Get Started to Find your lovely friends',
  ];
  static const descriptions = [
    'Find a companion to share your everyday moments. A little love is closer than you think.',
    'Meet caring pet lovers, share your pet’s story, and find the right home together.',
    'Meet your new best friend and make every day a little happier.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SoftBackground(
      child: LayoutBuilder(
        builder: (context, box) {
          if (step == -1) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Spacer(),
                    Image.asset(
                      'assets/images/brand.png',
                      width: 258,
                      semanticLabel: 'Findpet',
                    ),
                    const Spacer(),
                    const Text(
                      'Adopt and sell pets on a smartphone.\nA little friend. A lot of happiness.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 12, height: 1.8),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      'Get started',
                      onPressed: () => setState(() => step = 0),
                    ),
                  ],
                ),
              ),
            );
          }
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/${['onboarding-dog', 'onboarding-cat', 'onboarding-white-cat'][step]}.png',
                  height: box.maxHeight * .73,
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            box.maxHeight -
                            MediaQuery.paddingOf(context).vertical -
                            24,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    AppScope.of(context).finishOnboarding(),
                                child: const Text('Skip'),
                              ),
                            ),
                            SizedBox(
                              height: (box.maxHeight * .50 - 90).clamp(90, 500),
                            ),
                            Image.asset(
                              'assets/images/brand-mark.png',
                              width: 53,
                              height: 55,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              titles[step],
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              descriptions[step],
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.8,
                                color: muted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                for (int i = 0; i < 3; i++)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(right: 14),
                                    decoration: BoxDecoration(
                                      color: i == step
                                          ? orange
                                          : const Color(0xFFD9DBDD),
                                      shape: BoxShape.circle,
                                      boxShadow: i == step
                                          ? [
                                              const BoxShadow(
                                                color: cream,
                                                spreadRadius: 5,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            PrimaryButton(
                              step == 2 ? 'Let’s get started' : 'Next',
                              onPressed: () {
                                if (step == 2) {
                                  AppScope.of(context).finishOnboarding();
                                } else {
                                  setState(() => step++);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

enum AuthMode { login, register, forgot }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.mode = AuthMode.login});
  final AuthMode mode;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool hidden = true, accepted = false;
  bool get register => widget.mode == AuthMode.register;
  bool get forgot => widget.mode == AuthMode.forgot;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    if (forgot) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Demo request received'),
          content: const Text(
            'This local demo does not send email. In a connected app, a reset link would be sent to your email address.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context);
              },
              child: const Text('Back to login'),
            ),
          ],
        ),
      );
      return;
    }
    if (register && !accepted) {
      toast(context, 'Please accept the terms to continue');
      return;
    }
    AppScope.of(context)
        .signIn(register ? name.text : email.text.split('@').first);
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = forgot
        ? 'Forgot Password'
        : register
        ? 'Register'
        : 'Login';
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 44),
                child: IntrinsicHeight(
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (forgot)
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        else
                          Image.asset('assets/images/brand.png', width: 140),
                        SizedBox(height: forgot ? 130 : 110),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          forgot
                              ? 'Enter your email to reset your password'
                              : register
                              ? 'Create an account to start caring'
                              : 'Login with your account to continue',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 30),
                        if (register)
                          LabeledField(
                            '',
                            controller: name,
                            hint: 'Name',
                            validator: requiredText,
                          ),
                        LabeledField(
                          '',
                          controller: email,
                          hint: 'Email Address',
                          validator: emailValidator,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (!forgot)
                          LabeledField(
                            '',
                            controller: password,
                            hint: 'Password',
                            obscure: hidden,
                            validator: (v) => (v?.length ?? 0) < 6
                                ? 'Use at least 6 characters'
                                : null,
                            suffix: IconButton(
                              tooltip: hidden
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(() => hidden = !hidden),
                              icon: Icon(
                                hidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                                color: muted,
                              ),
                            ),
                          ),
                        if (forgot)
                          const Text(
                            'A connected account would receive a reset link by email.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.8,
                            ),
                          ),
                        if (register)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: accepted,
                                activeColor: orange,
                                onChanged: (v) => setState(() => accepted = v!),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Terms & privacy'),
                                      content: const Text(
                                        'This is an offline demonstration. Data stays on this device. No real account is created, no payment is made, and no message is delivered to another person. Use sample information while exploring.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c),
                                          child: const Text('Got it'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: const Text(
                                    'By signing up, I agree to the Terms and Conditions & Privacy Policy',
                                    style: TextStyle(fontSize: 10, height: 1.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (!register && !forgot) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => openPage(
                                context,
                                const AuthScreen(mode: AuthMode.forgot),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 11, color: muted),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Or explore with a demo profile',
                            style: TextStyle(fontSize: 11, color: muted),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () =>
                                AppScope.of(context).signIn('Anam'),
                            icon: const Icon(Icons.pets_outlined, size: 18),
                            label: const Text('Try the demo'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Color(0xFFE4E9E8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Spacer(),
                        if (!forgot)
                          Center(
                            child: TextButton(
                              onPressed: () => register
                                  ? Navigator.pop(context)
                                  : openPage(
                                      context,
                                      const AuthScreen(mode: AuthMode.register),
                                    ),
                              child: Text(
                                register
                                    ? 'Already have an account?  Login'
                                    : 'Don’t have an account yet?  Register',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          forgot
                              ? 'Submit'
                              : register
                              ? 'Create Account'
                              : 'Login',
                          onPressed: submit,
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Local demo · no real account required',
                            style: TextStyle(fontSize: 10, color: muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
