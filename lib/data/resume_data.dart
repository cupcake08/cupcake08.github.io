class ResumeData {
  static const String promptSymbol = "guest@ankit-sys:~\$ ";

  static const String intro = '''
INITIALIZING SYSTEM...
KERNEL LOADED.

WELCOME TO:
ANKIT BHANKHARIA [un-KIT bhan-KHAH-ri-yah]
Terminal Interface v1.0

[Mobile Developer • Part-Time Hardware Tinkerer | Building apps that play nice with the real world]

Location: Bangalore, Karnataka, India

Type 'help' for a list of executable commands.
''';

  static const String help = '''
AVAILABLE COMMANDS:
-------------------
  > about       : System profile & summary
  > experience  : Load work history modules
  > projects    : Mount technical projects
  > skills      : List technical capabilities
  > education   : Academic qualifications
  > contact     : Communication channels
  > clear       : Flush terminal buffer
''';

  // List of commands for Autocomplete
  static const List<String> knownCommands = [
    'help',
    'about',
    'experience',
    'projects',
    'skills',
    'education',
    'contact',
    'clear',
  ];

  static const String about = '''
SYSTEM PROFILE:
---------------
Results-driven Software Engineer with 3.5 years of experience.
Core competency: Transitioning from specialized mobile dev to scalable backend architecture.

Focus Areas:
- High-availability product development
- System performance optimization
- Hardware-software integration (Bluetooth, USB, Wi-Fi)
- Embedded systems development
''';

  static const String experience = '''
WORK HISTORY LOG:
-----------------

[2025.04 - 2025.08] Tarento Tech Pvt. Ltd.
> Role: Software Engineer
  - Engineered seamless payment gateway architecture.
  - Integrated dynamic map features with high-performance rendering.

[2025.01 - 2025.04] WYB
> Role: Software Engineer
  - Optimized inefficient SQL queries to resolve critical bottlenecks.
  - Implemented Dart Isolates, boosting performance by 40%.
  - Reduced crash rates by 15% via architectural stabilization.

[2023.05 - 2024.12] Carinfo
> Role: Software Developer
  - Architected backend-driven UI system for 1M+ active users.
  - Developed automation scripts for CI/CD workflows.
  - Managed full SDLC from concept to deployment.

[2022.05 - 2023.05] Soulguide Digital Pvt. Ltd.
> Role: Software Developer
  - Developed and launched two Flutter applications from scratch.
  - Managed end-to-end deployment to Google Play Store.
''';

  static const String projects = '''
MOUNTED PROJECTS:
-----------------
1. SECURE COMM APP (Indian Army) [HARDWARE INTEGRATION]
   - Real-time communication via Bluetooth, Wi-Fi, and USB peripherals.
   - Implemented AES-256 encryption.
   - Repo: <NDA>

2. GEOFENCE ALARM [SYSTEMS]
   - Battery-efficient background location tracking.
   - Custom radius triggers.
   - Repo: https://github.com/cupcake08/Geofence_Alarm

3. QUICKNOTES WIDGET
   - Home screen widget for quick note taking.
   - Repo: https://github.com/cupcake08/quicknotes-widget
   - Demo: https://x.com/bhankhariaa/status/1923960080556282031

4. ARDUINO MBEDTLS CLIENT
   - Secure client implementation for embedded systems.
   - Repo: https://github.com/cupcake08/Arduino-MbedTLS-Client

5. SAHELI (Hackathon Project)
   - Women's safety app connecting travelers.
   - Algorithmic matching for shared journeys.
   - Repo: https://github.com/sonigeez/saheli_app

6. FLUTTER UI CHALLENGES
   - Advanced custom widget engineering.
   - Repo: https://github.com/cupcake08/flutter-ui-challenges

OPEN SOURCE CONTRIBUTIONS:
--------------------------
> LocalSend (Cross-platform file sharing)
  - Contributed to the open-source ecosystem.
  - Repo: https://github.com/localsend/localsend

> DevCleaner (Developer tool)
  - Cleaning tool for developer environments.
  - Repo: https://github.com/jemishavasoya/dev-cleaner
''';

  static const String skills = '''
TECHNICAL STACK:
----------------
[LANGUAGES]  :: Dart, C, C++, Java, Go, SQL
[FRAMEWORK]  :: Flutter (Mobile & Web), PlatformIO
[BACKEND]    :: REST APIs, Microservices, System Design
[HARDWARE]   :: Bluetooth Low Energy (BLE), USB Serial, mDNS
[DEVOPS]     :: Docker, AWS, Git, CI/CD pipelines
[CORE]       :: DSA, OOP, Unit Testing, Security
''';

  static const String education = '''
ACADEMIC RECORDS:
-----------------
BCA (Bachelor of Computer Applications)
IGNOU, New Delhi (2021 - 2024)
Grade: A
''';

  static const String contact = '''
COMMUNICATION CHANNELS:
-----------------------
Phone  :: +91 9079897225
Email  :: bhankhariaa@pm.me
GitHub :: https://github.com/cupcake08
X (Tw) :: https://x.com/bhankhariaa
''';
}
