#import "SnapshotHelper.js"

UIALogger.logMessage("Starting")

var target = UIATarget.localTarget()
var app = target.frontMostApp()
var mainTable = app.tableViews()[0]
var backButton = app.navigationBar().leftButton()

// Action Buttons
app.mainWindow().tableViews()[0].cells()[0].tap()
UIATarget.localTarget().delay(0.6)
captureLocalizedScreenshot("Actions")
app.navigationBar().leftButton().tap()

// Compact Tweets
app.mainWindow().tableViews()[0].cells()[3].tap()
captureLocalizedScreenshot("Compact")
app.navigationBar().leftButton().tap()

// List
app.mainWindow().tableViews()[0].cells()[7].tap()
captureLocalizedScreenshot("List")
app.navigationBar().leftButton().tap()

// Regular Tweets
app.mainWindow().tableViews()[0].cells()[3].tap()
captureLocalizedScreenshot("Regular")
app.navigationBar().leftButton().tap()
