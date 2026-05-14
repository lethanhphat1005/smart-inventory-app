import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enBarcode = {
  TTexts.barcodeSimilarTitle: 'Similar Products Found',
  TTexts.barcodeSimilarDesc:
      'We found products that might match this barcode. Select one to link, or create a new one.',
  TTexts.barcodeLinkingLoader: 'Linking barcode...',
  TTexts.barcodeLinkSuccessMsg: 'Successfully linked barcode to this product.',
  TTexts.barcodeLinkConflictError:
      'Barcode conflict or linking error. Please try again.',
  TTexts.barcodeCreateNewBtn: 'Create Completely New Product',
  TTexts.barcodeNoDataTitle: 'No Data Found',
  TTexts.barcodeNoDataDesc:
      'This barcode is completely new. Would you like to add this product to the system?',
  TTexts.barcodeAddNewBtn: 'Add New Product',
  TTexts.barcodePrefillTitle: 'New Product Found',
  TTexts.barcodePrefillDesc:
      'Found product information online, but it is not in your store yet.',
  TTexts.barcodeAddToStoreBtn: 'Add to Store',
  TTexts.barcodeUnknown: 'Unknown',
  TTexts.barcodeCheckingLoader: 'Checking barcode...',
  TTexts.barcodeScanErrorTitle: 'Barcode Scan Error',
  TTexts.barcodeCopied: 'Barcode copied to clipboard!',
  TTexts.manualBarcodeEntryTitle: "Manual Barcode Entry",
  TTexts.manualBarcodeEntryDesc:
      "Enter the barcode manually if the scanner cannot read it.",
  TTexts.barcodeListTitle: "Barcode List",
  TTexts.sourceLabel: "Source",
  TTexts.sourceUserConfirmed: "Confirmed by user",
  TTexts.sourceSeed: "System sample data",
  TTexts.sourceAdmin: "Added by Admin",
  TTexts.sourceBarcodeFlow: "Created from scan flow",
  TTexts.sourceApi: "Imported via API",
  TTexts.sourceOther: "Other",
  TTexts.verifiedLabel: "Verified",
  TTexts.barcodeCandidateTitle: "Multiple Matches Found",
  TTexts.barcodeCandidateSubtitle: "Barcode",
  TTexts.barcodeMatchesMultipleProducts:
      "matches multiple products. Please select one:",
  TTexts.skipLabel: "Skip",
  TTexts.createProduct: "Create New",
  TTexts.barcodeScanHint: "Place the barcode in the center and hold still",
  TTexts.barcodeScanGalleryFailedTitle: "Scan Failed",
  TTexts.barcodeScanGalleryFailedDesc: "No valid barcode found in this image. Please try again with a clearer photo.",
};
