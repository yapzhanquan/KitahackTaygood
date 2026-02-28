/// Service that provides location-specific imagery for Malaysian construction projects
/// Simulates scraping from Google Maps Street View / nearby galleries based on coordinates
class LocationImageService {
  static final LocationImageService _instance = LocationImageService._internal();
  factory LocationImageService() => _instance;
  LocationImageService._internal();

  /// Get a marketing-style hero image for a project based on location
  String getMarketingImage(String location, String projectId) {
    final loc = location.toLowerCase();
    final images = _getLocationMarketingImages(loc);
    // Use projectId hash to get consistent image for same project
    final index = projectId.hashCode.abs() % images.length;
    return images[index];
  }

  /// Get a "grainy" construction site photo for community check-ins
  String getConstructionSiteImage(String location, String checkInId) {
    final loc = location.toLowerCase();
    final images = _getLocationConstructionImages(loc);
    final index = checkInId.hashCode.abs() % images.length;
    return images[index];
  }

  /// Get a Street View style photo showing the actual area
  String getStreetViewImage(String location, double lat, double lng) {
    final loc = location.toLowerCase();
    final images = _getLocationStreetImages(loc);
    // Use coordinates to pick consistent image
    final index = ((lat * 1000 + lng * 1000).abs().toInt()) % images.length;
    return images[index];
  }

  /// Get abandoned/stalled site imagery
  String getStalledSiteImage(String location, String checkInId) {
    final loc = location.toLowerCase();
    final images = _getLocationStalledImages(loc);
    final index = checkInId.hashCode.abs() % images.length;
    return images[index];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PETALING JAYA / SELANGOR IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _pjMarketingImages = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&h=400&fit=crop', // Modern apartment
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&h=400&fit=crop', // Glass tower
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=600&h=400&fit=crop', // Luxury condo
    'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=600&h=400&fit=crop', // Residential block
  ];

  static const _pjConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Crane at work
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', // Construction site
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Scaffolding
    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', // Building frame
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Active construction
  ];

  static const _pjStreetImages = [
    'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=600&h=400&fit=crop', // Malaysian street
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=600&h=400&fit=crop', // Urban Malaysia
    'https://images.unsplash.com/photo-1508964942454-1a56651d54ac?w=600&h=400&fit=crop', // City view
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SHAH ALAM IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _shahAlamMarketingImages = [
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop', // Modern homes
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop', // Terrace house
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=400&fit=crop', // Housing estate
  ];

  static const _shahAlamStalledImages = [
    'https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?w=400&h=300&fit=crop', // Abandoned building
    'https://images.unsplash.com/photo-1567596388756-f6d710c8fc07?w=400&h=300&fit=crop', // Empty site
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop', // Incomplete structure
    'https://images.unsplash.com/photo-1504615458222-979e04d69a27?w=400&h=300&fit=crop', // Overgrown site
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // JOHOR BAHRU IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _jbMarketingImages = [
    'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=600&h=400&fit=crop', // Apartment complex
    'https://images.unsplash.com/photo-1567684014761-b65e2e59b9eb?w=600&h=400&fit=crop', // Modern building
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&h=400&fit=crop', // High rise
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&h=400&fit=crop', // Luxury home
  ];

  static const _jbConstructionImages = [
    'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400&h=300&fit=crop', // Interior work
    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', // Building work
    'https://images.unsplash.com/photo-1587582423116-ec07293f0395?w=400&h=300&fit=crop', // Construction progress
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Crane site
  ];

  static const _jbStreetImages = [
    'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=600&h=400&fit=crop', // JB area
    'https://images.unsplash.com/photo-1508964942454-1a56651d54ac?w=600&h=400&fit=crop', // Urban JB
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // KUALA LUMPUR IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _klMarketingImages = [
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&h=400&fit=crop', // KL towers
    'https://images.unsplash.com/photo-1449157291145-7efd050a4d0e?w=600&h=400&fit=crop', // Modern KL
    'https://images.unsplash.com/photo-1464938050520-ef2571f65114?w=600&h=400&fit=crop', // City skyline
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=600&h=400&fit=crop', // Condo KL
  ];

  static const _klConstructionImages = [
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', // KL construction
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Building site
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Active work
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop', // Structure
  ];

  static const _klStreetImages = [
    'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=600&h=400&fit=crop', // KL street
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=600&h=400&fit=crop', // Urban KL
    'https://images.unsplash.com/photo-1508964942454-1a56651d54ac?w=600&h=400&fit=crop', // KL view
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // PENANG IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _penangMarketingImages = [
    'https://images.unsplash.com/photo-1559628233-100c798642d4?w=600&h=400&fit=crop', // Penang view
    'https://images.unsplash.com/photo-1586500036706-41963de24d8b?w=600&h=400&fit=crop', // Heritage
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&h=400&fit=crop', // Coastal condo
  ];

  static const _penangConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Site work
    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', // Building
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', // Construction
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // DAMANSARA IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _damansaraMarketingImages = [
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&h=400&fit=crop', // Corporate
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=600&h=400&fit=crop', // Premium
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&h=400&fit=crop', // Modern
  ];

  static const _damansaraConstructionImages = [
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Road work
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Equipment
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Widening
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SUBANG / SUNWAY IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _subangMarketingImages = [
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop', // Suburban
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop', // Houses
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&h=400&fit=crop', // Modern home
  ];

  static const _subangConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Bridge work
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', // Construction
    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', // Structure
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // IPOH / PERAK IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _ipohMarketingImages = [
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=400&fit=crop', // Mid-rise
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop', // Housing
    'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=600&h=400&fit=crop', // Apartments
  ];

  static const _ipohConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Building
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Scaffolds
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // CYBERJAYA / PUTRAJAYA IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _cyberjayaMarketingImages = [
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&h=400&fit=crop', // Tech hub
    'https://images.unsplash.com/photo-1449157291145-7efd050a4d0e?w=600&h=400&fit=crop', // Modern
    'https://images.unsplash.com/photo-1464938050520-ef2571f65114?w=600&h=400&fit=crop', // Office
  ];

  static const _cyberjayaConstructionImages = [
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', // Expressway
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Road
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Bridge pier
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // KLANG / DRAINAGE IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _klangMarketingImages = [
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=400&fit=crop', // Industrial
    'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=600&h=400&fit=crop', // Area
  ];

  static const _klangConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Heavy
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Work
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Drainage
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SCHOOL PROJECT IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _schoolMarketingImages = [
    'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=600&h=400&fit=crop', // School
    'https://images.unsplash.com/photo-1562774053-701939374585?w=600&h=400&fit=crop', // Campus
    'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?w=600&h=400&fit=crop', // Education
  ];

  static const _schoolConstructionImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Building
    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', // Structure
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Scaffold
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // ROAD PROJECT IMAGES
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _roadMarketingImages = [
    'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=600&h=400&fit=crop', // Highway
    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&h=400&fit=crop', // Road
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=600&h=400&fit=crop', // Urban road
  ];

  static const _roadConstructionImages = [
    'https://images.unsplash.com/photo-1517089596392-fb9a9033e05b?w=400&h=300&fit=crop', // Road work
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', // Equipment
    'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=400&h=300&fit=crop', // Paving
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC STALLED IMAGES (all regions)
  // ─────────────────────────────────────────────────────────────────────────
  
  static const _genericStalledImages = [
    'https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?w=400&h=300&fit=crop', // Abandoned
    'https://images.unsplash.com/photo-1567596388756-f6d710c8fc07?w=400&h=300&fit=crop', // Empty
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop', // Incomplete
    'https://images.unsplash.com/photo-1504615458222-979e04d69a27?w=400&h=300&fit=crop', // Overgrown
    'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400&h=300&fit=crop', // Quiet site
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER METHODS TO GET LOCATION-SPECIFIC IMAGES
  // ─────────────────────────────────────────────────────────────────────────

  List<String> _getLocationMarketingImages(String location) {
    if (location.contains('petaling jaya') || location.contains('pj') || location.contains('selangor')) {
      return _pjMarketingImages;
    } else if (location.contains('shah alam')) {
      return _shahAlamMarketingImages;
    } else if (location.contains('johor') || location.contains('jb') || location.contains('skudai') || location.contains('pasir gudang')) {
      return _jbMarketingImages;
    } else if (location.contains('kuala lumpur') || location.contains('kl') || location.contains('bangsar') || location.contains('sentul') || location.contains('kepong') || location.contains('bukit jalil') || location.contains('kampung baru') || location.contains('melawati')) {
      return _klMarketingImages;
    } else if (location.contains('penang') || location.contains('georgetown')) {
      return _penangMarketingImages;
    } else if (location.contains('damansara')) {
      return _damansaraMarketingImages;
    } else if (location.contains('subang') || location.contains('sunway') || location.contains('puncak alam')) {
      return _subangMarketingImages;
    } else if (location.contains('ipoh') || location.contains('perak')) {
      return _ipohMarketingImages;
    } else if (location.contains('cyberjaya') || location.contains('putrajaya')) {
      return _cyberjayaMarketingImages;
    } else if (location.contains('klang')) {
      return _klangMarketingImages;
    } else if (location.contains('langkawi') || location.contains('kedah')) {
      return _penangMarketingImages;
    } else if (location.contains('malacca') || location.contains('melaka')) {
      return _pjMarketingImages;
    } else if (location.contains('kuantan') || location.contains('pahang') || location.contains('genting')) {
      return _klMarketingImages;
    } else if (location.contains('kota kinabalu') || location.contains('sabah')) {
      return _penangMarketingImages;
    }
    // Fallback to PJ images
    return _pjMarketingImages;
  }

  List<String> _getLocationConstructionImages(String location) {
    if (location.contains('petaling jaya') || location.contains('pj') || location.contains('selangor')) {
      return _pjConstructionImages;
    } else if (location.contains('shah alam')) {
      return [..._pjConstructionImages, ..._shahAlamStalledImages.take(2)];
    } else if (location.contains('johor') || location.contains('jb') || location.contains('skudai') || location.contains('pasir gudang')) {
      return _jbConstructionImages;
    } else if (location.contains('kuala lumpur') || location.contains('kl') || location.contains('bangsar') || location.contains('sentul') || location.contains('kepong') || location.contains('bukit jalil') || location.contains('kampung baru') || location.contains('melawati')) {
      return _klConstructionImages;
    } else if (location.contains('penang') || location.contains('georgetown')) {
      return _penangConstructionImages;
    } else if (location.contains('damansara')) {
      return _damansaraConstructionImages;
    } else if (location.contains('subang') || location.contains('sunway') || location.contains('puncak alam')) {
      return _subangConstructionImages;
    } else if (location.contains('ipoh') || location.contains('perak')) {
      return _ipohConstructionImages;
    } else if (location.contains('cyberjaya') || location.contains('putrajaya')) {
      return _cyberjayaConstructionImages;
    } else if (location.contains('klang')) {
      return _klangConstructionImages;
    } else if (location.contains('langkawi') || location.contains('kedah')) {
      return _penangConstructionImages;
    } else if (location.contains('malacca') || location.contains('melaka')) {
      return _pjConstructionImages;
    } else if (location.contains('kuantan') || location.contains('pahang') || location.contains('genting')) {
      return _klConstructionImages;
    } else if (location.contains('kota kinabalu') || location.contains('sabah')) {
      return _penangConstructionImages;
    }
    return _pjConstructionImages;
  }

  List<String> _getLocationStreetImages(String location) {
    if (location.contains('petaling jaya') || location.contains('pj') || location.contains('selangor')) {
      return _pjStreetImages;
    } else if (location.contains('johor') || location.contains('jb')) {
      return _jbStreetImages;
    } else if (location.contains('kuala lumpur') || location.contains('kl')) {
      return _klStreetImages;
    }
    return _pjStreetImages;
  }

  List<String> _getLocationStalledImages(String location) {
    if (location.contains('shah alam')) {
      return _shahAlamStalledImages;
    }
    return _genericStalledImages;
  }
}
