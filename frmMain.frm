VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   0  'None
   Caption         =   "Transparent Form Example by Chad Roe"
   ClientHeight    =   3180
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   5070
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   Picture         =   "frmMain.frx":0CCA
   ScaleHeight     =   3180
   ScaleWidth      =   5070
   Begin VB.Label lblExit 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "X"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   210
      Left            =   315
      TabIndex        =   0
      Top             =   570
      Width           =   210
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
'@                                                                                       @'
'@ Ok everyone, after looking at all the transparency examples on PSCode, I decided to   @'
'@ write my own because all the others contain absurd amounts of code and could all be   @'
'@ made much smaller. This example uses a Function created by Robert Gainor that was     @'
'@ cleaned up a bit. Robert Gainor made it look like you needed 4 forms and 4 modules    @'
'@ just to create a transparent form when all you need is one form and one line of code. @'
'@                                                                                       @'
'@      Created by Chad Roe, Jeepman6@aol.com, http://www.offroadextremes.com/chad       @'
'@                                                                                       @'
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

'FormMove and FormOnTop Declarations and Constants
Private Declare Function ReleaseCapture Lib "user32" () As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Private Const HWND_TOPMOST = -1
Private Const SWP_NOMOVE = &H2
Private Const SWP_NOSIZE = &H1
Private Const Flags = SWP_NOMOVE Or SWP_NOSIZE

'Transparency Declarations and Constants
'I copied these from Robert Gainor's Example
Private Declare Function CreateRectRgn Lib "gdi32" (ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long) As Long
Private Declare Function CombineRgn Lib "gdi32" (ByVal hDestRgn As Long, ByVal hSrcRgn1 As Long, ByVal hSrcRgn2 As Long, ByVal nCombineMode As Long) As Long
Private Declare Function OffsetRgn Lib "gdi32" (ByVal hRgn As Long, ByVal X As Long, ByVal Y As Long) As Long
Private Declare Function SetWindowRgn Lib "user32" (ByVal hwnd As Long, ByVal hRgn As Long, ByVal bRedraw As Boolean) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hDC As Long, ByVal hObject As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Private Declare Function DeleteDC Lib "gdi32" (ByVal hDC As Long) As Long
Private Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hDC As Long) As Long
Private Declare Function GetPixel Lib "gdi32" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long) As Long
Private Const RGN_AND = 1
Private Const RGN_OR = 2
Private Const RGN_XOR = 3
Private Const RGN_DIFF = 4
Private Const RGN_COPY = 5

'FormMove and FormOnTop Subs
Private Sub FormOnTop(Frm As Form)
Call SetWindowPos(Frm.hwnd, HWND_TOPMOST, 0&, 0&, 0&, 0&, Flags)
End Sub

Private Sub FormMoveXP(Frm As Form)
Call ReleaseCapture
Call SendMessage(Frm.hwnd, &HA1, 2, 0&)
End Sub

Private Sub CenterForm(Frm As Form)
Frm.Left = Screen.Width / 2 - Frm.Width / 2
Frm.Top = Screen.Height / 2 - Frm.Height / 2
End Sub

'Transparency Function
'I copied this from Robert Gainor's Example
Private Function MakeTransparent(ByRef Frm As Form, ByVal TransparentColor As Long) As Long
Dim rgnMain As Long, rgnPixel As Long, bmpMain As Long, dcMain As Long
Dim Width As Long, Height As Long, X As Long, Y As Long
Dim ScaleSize As Long, RGBColor As Long
ScaleSize& = Frm.ScaleMode
Frm.ScaleMode = 3
Frm.BorderStyle = 0
Width& = Frm.ScaleX(Frm.Picture.Width, vbHimetric, vbPixels)
Height& = Frm.ScaleY(Frm.Picture.Height, vbHimetric, vbPixels)
Frm.Width = Width& * Screen.TwipsPerPixelX
Frm.Height = Height& * Screen.TwipsPerPixelY
rgnMain& = CreateRectRgn(0&, 0&, Width&, Height&)
dcMain& = CreateCompatibleDC(Frm.hDC)
bmpMain& = SelectObject(dcMain&, Frm.Picture.Handle)
For Y& = 0& To Height&
  For X& = 0& To Width&
    RGBColor& = GetPixel(dcMain&, X&, Y&)
    If RGBColor& = TransparentColor& Then
      rgnPixel& = CreateRectRgn(X&, Y&, X& + 1&, Y& + 1&)
      CombineRgn rgnMain&, rgnMain&, rgnPixel&, RGN_XOR
      DeleteObject rgnPixel&
    End If
  Next X&
Next Y&
SelectObject dcMain&, bmpMain&
DeleteDC dcMain&
DeleteObject bmpMain&
If rgnMain& <> 0& Then
  SetWindowRgn Frm.hwnd, rgnMain&, True
  MakeTransparent = rgnMain&
End If
Frm.ScaleMode = ScaleSize&
End Function

'Form Code
Private Sub Form_Load()
Call FormOnTop(Me)
Call CenterForm(Me)
Call MakeTransparent(Me, CLng(0))
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Call FormMoveXP(Me)
End Sub

Private Sub Form_Unload(Cancel As Integer)
End
End Sub

Private Sub lblExit_Click()
Call Unload(Me)
End Sub
