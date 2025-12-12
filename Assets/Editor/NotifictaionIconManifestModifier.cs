using UnityEditor;
using UnityEditor.Android;
using System.IO;
using System.Xml;

public class NotifictaionIconManifestModifier : IPostGenerateGradleAndroidProject
{
    public int callbackOrder => 100;

    public void OnPostGenerateGradleAndroidProject(string path)
    {
        string manifestPath = Path.Combine(path, "src/main/AndroidManifest.xml");
        if (!File.Exists(manifestPath))
            return;

        XmlDocument doc = new XmlDocument();
        doc.Load(manifestPath);

        XmlNamespaceManager nsMgr = new XmlNamespaceManager(doc.NameTable);
        nsMgr.AddNamespace("android", "http://schemas.android.com/apk/res/android");

        XmlNode applicationNode = doc.SelectSingleNode("/manifest/application");
        if (applicationNode == null)
            return;

        bool metaExists = false;
        foreach (XmlNode node in applicationNode.ChildNodes)
        {
            if (node.Name == "meta-data")
            {
                var nameAttr = node.Attributes["android:name"];
                var resAttr = node.Attributes["android:resource"];
                if (nameAttr != null && resAttr != null &&
                    nameAttr.Value == "com.google.firebase.messaging.default_notification_icon" &&
                    resAttr.Value == "@drawable/notificationicon")
                {
                    metaExists = true;
                    break;
                }
            }
        }

        if (!metaExists)
        {
            XmlElement metaData = doc.CreateElement("meta-data");
            metaData.SetAttribute("name", "http://schemas.android.com/apk/res/android", "com.google.firebase.messaging.default_notification_icon");
            metaData.SetAttribute("resource", "http://schemas.android.com/apk/res/android", "@drawable/notificationicon");
            applicationNode.AppendChild(metaData);
            doc.Save(manifestPath);
        }
    }
}
