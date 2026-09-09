import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const PrivacyPolicyContent(),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy for NS Electrical',
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
            'NS Electrical  is unwavering in our commitment to safeguarding your privacy and protecting your personal information. This comprehensive Privacy Policy delineates our practices regarding the collection, utilization, disclosure, and protection of your information when you engage with our sophisticated mobile application. We implore you to carefully review this privacy policy. If you do not consent to the terms outlined herein, we respectfully request that you refrain from accessing or utilizing our application.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Information Collection
          _buildSectionTitle('Information We Collect', isDarkMode),
          _buildParagraph(
            'We meticulously gather information that you directly provide to us during your interaction with our application, including but not limited to:',
            isDarkMode,
          ),
          _buildListItem(
            'Account credentials such as your email address during the registration process',
            isDarkMode,
          ),
          _buildListItem(
            'DTR (Distribution Transformer Record) data encompassing creation, modification, and deletion activities',
            isDarkMode,
          ),
          _buildListItem(
            'Comprehensive pole information and associated technical data',
            isDarkMode,
          ),
          _buildListItem(
            'Application preferences, configuration settings, and user customizations',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          _buildParagraph(
            'Additionally, we automatically collect technical information to enhance your user experience:',
            isDarkMode,
          ),
          _buildListItem(
            'Device specifications (device model, operating system version, hardware capabilities)',
            isDarkMode,
          ),
          _buildListItem(
            'Usage analytics (interaction patterns, feature utilization, session duration)',
            isDarkMode,
          ),
          _buildListItem(
            'Diagnostic information (error logs, performance metrics, system stability data)',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Use of Information
          _buildSectionTitle('How We Utilize Your Information', isDarkMode),
          _buildParagraph(
            'We strategically employ the collected information to optimize your experience and ensure seamless functionality:',
            isDarkMode,
          ),
          _buildListItem(
            'Deliver, maintain, and continuously enhance our cutting-edge application',
            isDarkMode,
          ),
          _buildListItem(
            'Process and securely store your DTR and pole data with industry-leading protocols',
            isDarkMode,
          ),
          _buildListItem(
            'Provide responsive customer support and address your inquiries',
            isDarkMode,
          ),
          _buildListItem(
            'Disseminate technical notifications and critical support communications',
            isDarkMode,
          ),
          _buildListItem(
            'Analyze usage trends and preferences to inform future development',
            isDarkMode,
          ),
          _buildListItem(
            'Diagnose and rectify technical issues to ensure optimal performance',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Data Storage
          _buildSectionTitle('Data Storage and Security Protocols', isDarkMode),
          _buildParagraph(
            'Your sensitive data is securely stored locally on your device utilizing SharedPreferences technology for unparalleled performance and reliability. We implement robust security measures to fortify your information against unauthorized access:',
            isDarkMode,
          ),
          _buildListItem(
            'Advanced data encryption protocols for data at rest',
            isDarkMode,
          ),
          _buildListItem(
            'Sophisticated authentication mechanisms and access controls',
            isDarkMode,
          ),
          _buildListItem(
            'Comprehensive security assessments and vulnerability scanning',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Data Sharing
          _buildSectionTitle('Information Sharing and Disclosure', isDarkMode),
          _buildParagraph(
            'We maintain an absolute prohibition against selling, trading, or transferring your personally identifiable information to external entities. Your confidential data remains exclusively on your device and is never shared with third parties except under legally mandated circumstances or court orders.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Data Retention
          _buildSectionTitle('Data Retention and Deletion', isDarkMode),
          _buildParagraph(
            'We retain your information for the duration necessary to fulfill our service obligations or as mandated by applicable legal frameworks. You possess complete autonomy to delete your data at any time through application uninstallation or by utilizing our integrated deletion functions within the app.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Your Rights
          _buildSectionTitle('Your Privacy Rights and Controls', isDarkMode),
          _buildParagraph(
            'You are entitled to exercise comprehensive control over your personal information:',
            isDarkMode,
          ),
          _buildListItem(
            'Access and review your complete personal information portfolio',
            isDarkMode,
          ),
          _buildListItem(
            'Update or rectify any inaccuracies in your information',
            isDarkMode,
          ),
          _buildListItem(
            'Permanently delete your information from our systems',
            isDarkMode,
          ),
          _buildListItem(
            'Object to or restrict the processing of your information',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Children's Privacy
          _buildSectionTitle('Children\'s Privacy Protection', isDarkMode),
          _buildParagraph(
            'Our application is specifically designed for professional use and is not intended for individuals under the age of 13. We conscientiously avoid collecting personal information from minors. Should we inadvertently collect information from a child under 13, we will promptly implement measures to expunge such data.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Changes to Privacy Policy
          _buildSectionTitle('Amendments to This Privacy Policy', isDarkMode),
          _buildParagraph(
            'We reserve the right to periodically update our Privacy Policy to reflect evolving practices and legal requirements. We will notify you of significant changes by publishing the revised Privacy Policy on this page and updating the "Last Updated" timestamp.',
            isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Contact Information
          _buildSectionTitle('Contact Us', isDarkMode),
          _buildParagraph(
            'For inquiries regarding this Privacy Policy or to exercise your privacy rights, please contact our dedicated support team:',
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