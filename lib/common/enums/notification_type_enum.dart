enum NotificationType {general, message, order}

NotificationType? getNotificationTypeEnum(String? type){
  switch(type){
    case 'general':
      return NotificationType.general;
    case 'message':
      return NotificationType.message;
    case 'order':
      return NotificationType.order;
  }
  return null;
}