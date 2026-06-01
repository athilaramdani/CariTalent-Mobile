class ApiEndpoints {
  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authLogout = '/auth/logout';
  static const authMe = '/auth/me';

  // Collections
  static const events = '/events';
  static const talents = '/talents';
  static const genres = '/genres';
  static const notifications = '/notifications';

  // My resources
  static const myTalent = '/talents/my';
  static const myApplications = '/applications/my';
  static const myInvitations = '/invitations/my';
  static const myBookings = '/bookings/my';
  static const myReviews = '/reviews/my';
  static const myEvents = '/events/my';
  static const sentInvitations = '/invitations/sent';

  // User profile
  static const userProfile = '/users/profile';
  static const userPassword = '/users/password';

  // Applications
  static const applications = '/applications';
  static String applicationStatus(int id) => '/applications/$id/status';
  static String cancelApplication(int id) => '/applications/$id';

  // Invitations
  static const invitations = '/invitations';
  static String respondInvitation(int id) => '/invitations/$id/respond';

  // Bookings
  static String completeBooking(int id) => '/bookings/$id/complete';
  static String cancelBooking(int id) => '/bookings/$id/cancel';

  // Event sub-resources
  static String updateEvent(int id) => '/events/$id';
  static String deleteEvent(int id) => '/events/$id';
  static String eventApplications(int eventId) => '/events/$eventId/applications';
  static String eventRecommendations(int eventId) =>
      '/events/$eventId/recommendations';

  // Talent sub-resources
  static String talentDetail(int id) => '/talents/$id';
  static String updateTalent(int id) => '/talents/$id';
  static String talentReviews(int id) => '/talents/$id/reviews';
}
