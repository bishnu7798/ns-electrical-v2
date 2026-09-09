import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const TermsOfServiceContent(),
    );
  }
}

class TermsOfServiceContent extends StatelessWidget {
  const TermsOfServiceContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms of Service for NS Electrical',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Last Updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Introduction
          _buildSectionTitle('Introduction', isDarkMode),
          _buildParagraph(
            'Welcome to NS Electrical, a premier provider of sophisticated electrical distribution management solutions. These comprehensive Terms of Service ("Terms") constitute a legally binding agreement governing your access to and utilization of our cutting-edge mobile application ("App"). By accessing or utilizing the App, you unequivocally agree to be bound by these Terms and our Privacy Policy, which together form the complete agreement between you and NS Electrical.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Eligibility
          _buildSectionTitle('Eligibility Requirements', isDarkMode),
          _buildParagraph(
            'You must be a minimum of 13 years of age to utilize this App. By engaging with the App, you represent and warrant that you possess the legal capacity to enter into this agreement and meet all specified eligibility criteria.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Account Registration
          _buildSectionTitle('Account Registration and Security', isDarkMode),
          _buildParagraph(
            'To access premium features of the App, account registration may be required. You covenant and agree to:',
            isDarkMode,
          ),
          _buildListItem(
            'Furnish accurate, current, and complete information during the registration process',
            isDarkMode,
          ),
          _buildListItem(
            'Maintain and promptly update your information to ensure its accuracy and completeness',
            isDarkMode,
          ),
          _buildListItem(
            'Safeguard your password confidentiality and implement robust security measures',
            isDarkMode,
          ),
          _buildListItem(
            'Immediately notify us of any unauthorized access or security breaches',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Use of the App
          _buildSectionTitle('Acceptable Use Policy', isDarkMode),
          _buildParagraph(
            'You agree to utilize the App exclusively for lawful purposes and in strict compliance with these Terms. You expressly covenant not to:',
            isDarkMode,
          ),
          _buildListItem(
            'Utilize the App in any manner that violates applicable laws, regulations, or industry standards',
            isDarkMode,
          ),
          _buildListItem(
            'Engage in unauthorized access to or exploitation of our systems and infrastructure',
            isDarkMode,
          ),
          _buildListItem(
            'Interfere with or disrupt the operation, security, or performance of the App',
            isDarkMode,
          ),
          _buildListItem(
            'Transmit any malicious code, viruses, or harmful technological elements',
            isDarkMode,
          ),
          _buildListItem(
            'Attempt to circumvent, disable, or otherwise compromise security mechanisms',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Data and Content
          _buildSectionTitle('Data Ownership and Licensing', isDarkMode),
          _buildParagraph(
            'You retain absolute ownership of all data you input into the App, including DTR records and pole information. By utilizing the App, you grant us a non-exclusive, worldwide license to store, process, and display your data solely for the purpose of delivering the App\'s functionality and services.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Intellectual Property
          _buildSectionTitle('Intellectual Property Rights', isDarkMode),
          _buildParagraph(
            'The App and its entire contents, features, and functionality are proprietary assets of NS Electrical or its licensors, protected by international copyright, trademark, and other intellectual property laws. Unauthorized use of any intellectual property is strictly prohibited.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Disclaimer of Warranties
          _buildSectionTitle('Disclaimer of Warranties', isDarkMode),
          _buildParagraph(
            'The App is provided "as is" and "as available" without any warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, secure, error-free, or completely free of vulnerabilities. All services are provided without warranty of any kind.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Limitation of Liability
          _buildSectionTitle('Limitation of Liability', isDarkMode),
          _buildParagraph(
            'To the fullest extent permitted by applicable law, NS Electrical shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits, revenues, business, or data, arising out of or related to your use of the App.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Indemnification
          _buildSectionTitle('Indemnification Obligations', isDarkMode),
          _buildParagraph(
            'You agree to indemnify, defend, and hold harmless NS Electrical and its affiliates, officers, directors, employees, and agents from any claims, liabilities, damages, losses, or expenses, including reasonable attorneys\' fees, arising out of or related to your use of the App or violation of these Terms.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Termination
          _buildSectionTitle('Termination Rights', isDarkMode),
          _buildParagraph(
            'We reserve the right to terminate or suspend your access to the App at any time, without prior notice or liability, for any reason, including but not limited to breach of these Terms, security concerns, or operational requirements.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Changes to Terms
          _buildSectionTitle('Amendments to These Terms', isDarkMode),
          _buildParagraph(
            'We retain the unilateral right to modify these Terms at any time to reflect changes in our services, legal requirements, or business practices. We will notify you of material changes by posting the revised Terms on this page and updating the "Last Updated" date.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Governing Law
          _buildSectionTitle('Governing Law and Jurisdiction', isDarkMode),
          _buildParagraph(
            'These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions. Any disputes arising from these Terms shall be resolved exclusively in the courts of [Your Jurisdiction].',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Contact Information
          _buildSectionTitle('Contact Us', isDarkMode),
          _buildParagraph(
            'For inquiries regarding these Terms of Service or to report violations, please contact our legal department:',
            isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
             'Email: bishnu4321@gmail.com\n'
            'Create with ❤️ by Nirmalya Sarkar',
            isDarkMode,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.blue[300]! : Colors.blue,
      ),
    );
  }
  
  Widget _buildParagraph(String text, bool isDarkMode) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
      ),
    );
  }
  
  Widget _buildListItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}