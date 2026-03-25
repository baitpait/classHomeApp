import 'package:hexacom_user/localization/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Arabic / English / Hebrew for keys where JSON may be missing; Hebrew must not fall back to English here.
String _localeTriple(String languageCode, String ar, String en, String he) {
  if (languageCode == 'ar') return ar;
  if (languageCode == 'he') return he;
  return en;
}

/// Fallback for known keys when JSON translation is missing (e.g. after adding new key without full restart).
String? _fallbackFor(String? key, String languageCode) {
  if (key == null) return null;
  final isArabic = languageCode == 'ar';
  final isHebrew = languageCode == 'he';
  switch (key) {
    case 'store':
      if (isArabic) return 'المتجر';
      if (isHebrew) return 'חנות';
      return 'Store';
    case 'explore_popular_categories':
      if (isArabic) return 'استكشف التصنيفات الشائعة';
      if (isHebrew) return 'חקור קטגוריות פופולריות';
      return 'Explore Popular Categories';
    case 'home':
      if (isArabic) return 'الرئيسية';
      if (isHebrew) return 'בית';
      return 'Home';
    case 'view_all':
      if (isArabic) return 'عرض الكل';
      if (isHebrew) return 'הצג הכל';
      return 'View All';
    case 'search_for_products':
      if (isArabic) return 'ابحث عن المنتجات';
      if (isHebrew) return 'חפש מוצרים';
      return 'Search for Products';
    case 'search_items_here':
      if (isArabic) return 'ابحث عن المنتجات';
      if (isHebrew) return 'חפש מוצרים';
      return 'Search for Products';
    case 'language':
      if (isArabic) return 'اللغة';
      if (isHebrew) return 'שפה';
      return 'Language';
    case 'enter_email_phone':
      if (isArabic) return 'أدخل البريد الإلكتروني أو رقم الجوال';
      if (isHebrew) return 'נא להזין אימייל או טלפון';
      return 'Please enter email or phone';
    case 'contact_person':
      return _localeTriple(
          languageCode, 'اسم جهة الاتصال', 'Contact person', 'איש קשר');
    case 'phone':
      return _localeTriple(languageCode, 'رقم الهاتف', 'Phone', 'טלפון');
    case 'flash_sale':
      if (isArabic) return 'عروض حصرية';
      if (isHebrew) return 'מבצע בזק';
      return 'Flash Sale';
    case 'pickup_thank_you':
      return _localeTriple(languageCode, 'شكراً لطلبك.', 'Thank you for your order.',
          'תודה על הזמנתך.');
    case 'pickup_instructions':
      return _localeTriple(
          languageCode,
          'يرجى القدوم إلى المتجر لاستلام طلبك.',
          'Please come to the store to collect your order.',
          'נא להגיע לחנות לאסוף את ההזמנה.');
    case 'loyalty_points':
      return _localeTriple(
          languageCode, 'نقاط الولاء', 'Loyalty points', 'נקודות נאמנות');
    case 'use_loyalty_points':
      return _localeTriple(languageCode, 'استخدام نقاط الولاء',
          'Use loyalty points', 'השתמש בנקודות נאמנות');
    case 'available':
      return _localeTriple(languageCode, 'متاح', 'Available', 'זמין');
    case 'points':
      return _localeTriple(languageCode, 'نقاط', 'points', 'נקודות');
    case 'loyalty_discount':
      return _localeTriple(languageCode, 'خصم نقاط الولاء',
          'Loyalty discount', 'הנחת נקודות נאמנות');
    case 'contact_us':
      return _localeTriple(
          languageCode, 'تواصل معنا', 'Contact us', 'צור קשר');
    case 'whatsapp_chat':
      return _localeTriple(languageCode, 'محادثة واتساب', 'WhatsApp Chat',
          'צ\'אט וואטסאפ');
    case 'telegram_chat':
      return _localeTriple(languageCode, 'محادثة تيليجرام', 'Telegram Chat',
          'צ\'אט טלגרם');
    case 'messenger_chat':
      return _localeTriple(languageCode, 'محادثة ماسنجر', 'Messenger Chat',
          'צ\'אט מסנג\'ר');
    case 'your_message':
      return _localeTriple(
          languageCode, 'رسالتك', 'Your message', 'ההודעה שלך');
    case 'send':
      return _localeTriple(languageCode, 'إرسال', 'Send', 'שלח');
    case 'message_sent_successfully':
      return _localeTriple(
          languageCode,
          'تم إرسال رسالتك بنجاح',
          'Message sent successfully',
          'ההודעה נשלחה בהצלחה');
    case 'contact_success_message':
      return _localeTriple(
          languageCode,
          'تم إرسال رسالتك بنجاح، سنتواصل معك قريباً.',
          'Your message has been sent successfully. We will contact you soon.',
          'ההודעה נשלחה בהצלחה, ניצור קשר בקרוב.');
    case 'subject':
      return _localeTriple(languageCode, 'الموضوع', 'Subject', 'נושא');
    case 'subject_inquiry':
      return _localeTriple(languageCode, 'استفسار', 'Inquiry', 'פנייה');
    case 'subject_complaint':
      return _localeTriple(languageCode, 'شكوى', 'Complaint', 'תלונה');
    case 'subject_suggestion':
      return _localeTriple(languageCode, 'اقتراح', 'Suggestion', 'הצעה');
    case 'subject_order_issue':
      return _localeTriple(
          languageCode, 'مشكلة في الطلب', 'Order issue', 'בעיה בהזמנה');
    case 'subject_other':
      return _localeTriple(languageCode, 'أخرى', 'Other', 'אחר');
    case 'name_required':
      return _localeTriple(
          languageCode, 'الاسم مطلوب', 'Name is required', 'השם נדרש');
    case 'email_required':
      return _localeTriple(languageCode, 'البريد الإلكتروني مطلوب',
          'Email is required', 'האימייל נדרש');
    case 'email_invalid':
      return _localeTriple(
          languageCode,
          'الرجاء إدخال بريد إلكتروني صحيح',
          'Please enter a valid email address',
          'נא להזין כתובת אימייל תקינה');
    case 'message_required':
      return _localeTriple(languageCode, 'نص الرسالة مطلوب',
          'Message is required', 'תוכן ההודעה נדרש');
    case 'throttle_message':
      return _localeTriple(
          languageCode,
          'لقد أرسلت عدداً كبيراً من الرسائل في وقت قصير، الرجاء المحاولة لاحقاً.',
          'Too many messages sent. Please try again later.',
          'נשלחו יותר מדי הודעות בזמן קצר, נסו שוב מאוחר יותר.');
    case 'sending':
      return _localeTriple(languageCode, 'جاري الإرسال…', 'Sending…', 'שולח…');
    case 'filter':
      return _localeTriple(languageCode, 'فلتر', 'Filter', 'מסנן');
    case 'customer_service':
      return _localeTriple(
          languageCode, 'خدمة العملاء', 'Customer service', 'שירות לקוחות');
    case 'send_timeout_with_server':
      return _localeTriple(
          languageCode,
          'انتهت مهلة الاتصال بالخادم، حاول مرة أخرى.',
          'Request timeout with server, please try again.',
          'פג תוקף הבקשה לשרת, נסו שוב.');
    case 'incorrect_certificate':
      return _localeTriple(
          languageCode,
          'شهادة الأمان غير صحيحة، الرجاء المحاولة لاحقاً.',
          'Incorrect security certificate, please try again later.',
          'תעודת אבטחה שגויה, נסו שוב מאוחר יותר.');
    case 'unavailable_to_process_data':
      return _localeTriple(
          languageCode,
          'تعذر معالجة الطلب حالياً، حاول لاحقاً.',
          'Unable to process your request right now. Please try again later.',
          'לא ניתן לעבד את הבקשה כעת, נסו שוב מאוחר יותר.');
    case 'server_error':
      return _localeTriple(
          languageCode,
          'حدث خطأ في الخادم، حاول لاحقاً.',
          'A server error occurred, please try again later.',
          'שגיאת שרת, נסו שוב מאוחר יותר.');
    case 'request_cancelled':
      return _localeTriple(
          languageCode,
          'تم إلغاء الطلب، حاول مرة أخرى إذا لزم الأمر.',
          'Request was cancelled, please try again if needed.',
          'הבקשה בוטלה, נסו שוב אם נדרש.');
    case 'delivery_address':
      return _localeTriple(languageCode, 'عنوان التوصيل', 'Delivery address',
          'כתובת למשלוח');
    case 'address':
      return _localeTriple(languageCode, 'العنوان', 'Address', 'כתובת');
    case 'tags':
      return _localeTriple(
          languageCode, 'وسوم المنتجات', 'Product tags', 'תגיות מוצר');
    case 'attributes':
      return _localeTriple(languageCode, 'الخصائص', 'Attributes', 'מאפיינים');
    case 'in_stock_only':
      return _localeTriple(
          languageCode, 'المتوفر فقط', 'In stock only', 'במלאי בלבד');
    case 'low_stock':
      return _localeTriple(languageCode, 'قارب على النفاد', 'Low stock',
          'מלאי מוגבל');
    case 'out_of_stock':
      return _localeTriple(
          languageCode, 'غير متوفر', 'Out of stock', 'אזל מהמלאי');
    case 'stock_run_out':
      return _localeTriple(
          languageCode, 'نفذت الكمية', 'Out of stock', 'אזל מהמלאי');
    case 'in_stock':
      return _localeTriple(languageCode, 'متوفر', 'In stock', 'במלאי');
    case 'limited_stock':
      return _localeTriple(
          languageCode, 'كمية محدودة', 'Limited stock', 'מלאי מוגבל');
    case 'topRated':
      return _localeTriple(
          languageCode, 'الأعلى تقييماً', 'Top rated', 'הדירוג הגבוה ביותר');
    case 'bestSelling':
      return _localeTriple(
          languageCode, 'الأكثر مبيعاً', 'Best selling', 'הנמכרים ביותר');
    case 'newArrivals':
      if (isArabic) return 'الأحدث';
      if (isHebrew) return 'הגעה חדשה';
      return 'New arrivals';
    case 'new_arrival':
      if (isArabic) return 'وصل حديثاً';
      if (isHebrew) return 'חדש הגיע';
      return 'New arrival';
    case 'back_in_stock':
      return _localeTriple(
          languageCode, 'عاد للتوفر', 'Back in stock', 'חזר למלאי');
    case 'offerProducts':
      if (isArabic) return 'العروض';
      if (isHebrew) return 'הצע מוצרים';
      return 'Offers';
    case 'priceLowToHigh':
      return _localeTriple(languageCode, 'السعر: من الأقل للأعلى',
          'Price: low to high', 'מחיר: מנמוך לגבוה');
    case 'priceHighToLow':
      return _localeTriple(languageCode, 'السعر: من الأعلى للأقل',
          'Price: high to low', 'מחיר: מגבוה לנמוך');
    case 'aToz':
      return _localeTriple(
          languageCode, 'الاسم: أ–ي', 'Name: A to Z', 'שם: א׳–ת׳');
    case 'zToa':
      return _localeTriple(
          languageCode, 'الاسم: ي–أ', 'Name: Z to A', 'שם: ת׳–א׳');
    case 'my_points':
      return _localeTriple(
          languageCode, 'نقاطي', 'My points', 'הנקודות שלי');
    case 'total_purchases':
      return _localeTriple(
          languageCode, 'إجمالي المشتريات', 'Total purchases', 'סה״כ רכישות');
    case 'loyalty_rules_earn':
      return _localeTriple(
          languageCode,
          'اكتساب النقاط: كل X ريال تشتريها تحصل على Y نقطة',
          'Earn: every X spent you get Y points',
          'צבירת נקודות: כל X שקנית — Y נקודות');
    case 'loyalty_rules_redeem':
      return _localeTriple(
          languageCode,
          'استبدال النقاط: كل نقطة = Z ريال خصم',
          'Redeem: 1 point = Z discount',
          'מימוש נקודות: כל נקודה = Z הנחה');
    case 'spend_more_to_reach':
      return _localeTriple(languageCode, 'مشتريات للوصول إلى', 'spend to reach',
          'רכישה נוספת כדי להגיע ל');
    case 'points_history':
      return _localeTriple(
          languageCode, 'سجل النقاط', 'Points history', 'היסטוריית נקודות');
    case 'level':
      return _localeTriple(languageCode, 'المستوى', 'Level', 'רמה');
    case 'load_points_failed':
      return _localeTriple(languageCode, 'تعذر تحميل النقاط',
          'Could not load points', 'לא ניתן לטעון נקודות');
    case 'retry':
      return _localeTriple(languageCode, 'إعادة المحاولة', 'Retry', 'נסה שוב');
    case 'you_will_earn_points_on_delivery':
      return _localeTriple(
          languageCode,
          'ستحصل على %s نقطة عند تسليم الطلب',
          'You will earn %s points on delivery',
          'תקבל %s נקודות במסירת ההזמנה');
    case 'loyalty_points_to_use':
      return _localeTriple(languageCode, 'سيتم استخدام %s نقطة',
          'Will use %s points', 'ייושמו %s נקודות');
    case 'without_coupon':
      return _localeTriple(
          languageCode, 'بدون كوبون', 'No coupon', 'ללא קופון');
    case 'delete_account_title_hint':
      return _localeTriple(
          languageCode,
          'إجراء دائم — لا يمكن التراجع',
          'Permanent — cannot be undone',
          'פעולה קבועה — לא ניתן לבטל');
    case 'whatsapp_mobile_number':
      return _localeTriple(
          languageCode,
          'رقم الجوال (واتساب)',
          'WhatsApp Mobile Number',
          'מספר טלפון (וואטסאפ)');
    case 'enter_whatsapp_mobile_number':
      return _localeTriple(
          languageCode,
          'أدخل رقم الجوال (واتساب)',
          'Enter WhatsApp mobile number',
          'הזן מספר טלפון (וואטסאפ)');
    case 'social_follow_us_title':
      return _localeTriple(
          languageCode,
          'تابعنا على وسائل التواصل',
          'Follow us on social media',
          'עקבו אחרינו ברשתות החברתיות');
    case 'social_follow_us_subtitle':
      return _localeTriple(
          languageCode,
          'كن أول من يعرف عن آخر العروض والأخبار',
          'Be the first to know about new offers & updates',
          'היו הראשונים לשמוע על מבצעים ועדכונים');
    case 'filters':
      return _localeTriple(languageCode, 'الفلاتر', 'Filters', 'מסננים');
    case 'filters_applied':
      return _localeTriple(
          languageCode, 'تم تطبيق تصفية', 'Filters applied', 'הוחל סינון');
    case 'select_subject_optional':
      return _localeTriple(
          languageCode,
          'اختر الموضوع (اختياري)',
          'Select subject (optional)',
          'בחר נושא (אופציונלי)');
    // Core nav / menu / footer (runtime evidence: bundled he.json can still expose English
    // while repo he.json is Hebrew — fb must win for locale he via merge order fb ?? fromJson).
    case 'guest':
      return _localeTriple(languageCode, 'زائر', 'Guest', 'אורח');
    case 'profile':
      return _localeTriple(languageCode, 'حسابي', 'Profile', 'פרופיל');
    case 'my_order':
      return _localeTriple(languageCode, 'طلباتي', 'My Order', 'ההזמנות שלי');
    case 'track_order':
      return _localeTriple(languageCode, 'تتبع الطلب', 'Track Order', 'מעקב הזמנה');
    case 'notification':
      return _localeTriple(
          languageCode, 'الإشعارات', 'Notification', 'התראות');
    case 'privacy_policy':
      return _localeTriple(
          languageCode, 'سياسة الخصوصية', 'Privacy Policy', 'מדיניות פרטיות');
    case 'terms_and_condition':
      return _localeTriple(languageCode, 'الشروط والأحكام', 'Terms & Conditions',
          'תנאים והגבלות');
    case 'about_us':
      return _localeTriple(languageCode, 'من نحن', 'About Us', 'אודותינו');
    case 'login':
      return _localeTriple(
          languageCode, 'تسجيل الدخول', 'Login', 'התחברות');
    case 'logout':
      return _localeTriple(
          languageCode, 'تسجيل الخروج', 'Logout', 'התנתקות');
    case 'order':
      return _localeTriple(languageCode, 'الطلب', 'Order', 'הזמנה');
    case 'quick_links':
      return _localeTriple(
          languageCode, 'روابط سريعة', 'Quick Links', 'קישורים מהירים');
    case 'my_account':
      return _localeTriple(languageCode, 'حسابي', 'My Account', 'החשבון שלי');
    case 'offer_product':
      return _localeTriple(
          languageCode, 'عروض المنتجات', 'Offer Products', 'הצע מוצרים');
    case 'refund_policy':
      return _localeTriple(
          languageCode, 'سياسة الاسترداد', 'Refund policy', 'מדיניות החזר');
    case 'return_policy':
      return _localeTriple(
          languageCode, 'سياسة الإرجاع', 'Return policy', 'מדיניות החזרה');
    case 'cancellation_policy':
      return _localeTriple(languageCode, 'سياسة الإلغاء', 'Cancellation policy',
          'מדיניות ביטול');
    case 'delete_account':
      return _localeTriple(
          languageCode, 'حذف الحساب', 'Delete account', 'מחיקת חשבון');
    case 'contact_us_subtitle':
      return _localeTriple(
          languageCode,
          'نرد خلال وقت قصير. اترك رسالتك وسنتواصل معك.',
          'We reply quickly. Leave your message and we\'ll get back to you.',
          'אנו עונים במהירות. השארו הודעה ונחזור אליכם.');
    case 'map_no_store_coordinates':
      return _localeTriple(
          languageCode,
          'لا توجد إحداثيات للمتجر لعرض الخريطة.',
          'No store coordinates available to display the map.',
          'אין קואורדינטות חנות להצגת המפה.');
    case 'footer_developer_credit':
      return _localeTriple(
          languageCode,
          'تطوير وبرمجة بيت البرمجيات وتكنولوجيا المعلومات',
          'Development by Bait Al Software & IT',
          'פיתוח ותכנות: בית התוכנה וטכנולוגיית המידע');
    default:
      return null;
  }
}

String getTranslated(String? key, BuildContext context) {
  String? fromJson;
  final languageCode = Localizations.localeOf(context).languageCode;
  try {
    fromJson = AppLocalization.of(context)?.translate(key);
  } catch (error) {
    if (kDebugMode) {
      print('not localized --- $error');
    }
  }
  final String? fb = _fallbackFor(key, languageCode);
  // Hebrew: prefer in-code fallbacks when present so stale/cached en strings in he.json
  // cannot override Hebrew (runtime evidence: fromJson was English while repo he.json is Hebrew).
  String? text = languageCode == 'he'
      ? (fb ?? fromJson ?? key)
      : (fromJson ?? fb ?? key);
  // Ensure flash_sale always shows correct Arabic label (overrides any cached JSON)
  if (key == 'flash_sale' && languageCode == 'ar') {
    text = 'عروض حصرية';
  } else if (key == 'flash_sale' && languageCode == 'he') {
    text = 'מבצע בזק';
  }
  // Ensure pickup strings always translated (override raw key or cached JSON)
  if (key == 'pickup_thank_you') {
    if (languageCode == 'ar') {
      text = 'شكراً لطلبك.';
    } else if (languageCode == 'he') {
      text = 'תודה על הזמנתך.';
    } else {
      text = 'Thank you for your order.';
    }
  } else if (key == 'pickup_instructions') {
    if (languageCode == 'ar') {
      text = 'يرجى القدوم إلى المتجر لاستلام طلبك.';
    } else if (languageCode == 'he') {
      text = 'נא להגיע לחנות לאסוף את ההזמנה.';
    } else {
      text = 'Please come to the store to collect your order.';
    }
  }
  return text ?? '';
}