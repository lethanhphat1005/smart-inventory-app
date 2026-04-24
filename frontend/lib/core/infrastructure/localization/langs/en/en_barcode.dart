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
};
