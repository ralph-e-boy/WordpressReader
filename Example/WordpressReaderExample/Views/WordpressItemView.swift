//
//  WordpressItemView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI
import WordpressReader

@available(iOS 15, *)
struct WordpressItemView<T: WordpressItem>: View {
    let item: T
    
    init(_ item: T) {
        self.item = item
    }
    
    private func attributedString(from html: String) -> AttributedString? {
        guard let htmlData = html.data(using: .utf8),
              let nsAttributedString = try? NSAttributedString(data: htmlData,
                                                               options: [.documentType: NSAttributedString.DocumentType.html,
                                                                         .characterEncoding: String.Encoding.utf8.rawValue],
                                                               documentAttributes: nil) else {
            return nil
        }
        let mutableString = NSMutableAttributedString(attributedString: nsAttributedString)
        mutableString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: NSRange(location: 0, length: mutableString.length))
        return AttributedString(mutableString)
    }
    
    var title: String {
        if let item = item as? WordpressPost {
            return item.titleCleaned
        } else if let item = item as? WordpressPage {
            return item.titleCleaned
        } else {
            return item.slug
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("ID")) {
                Link("\(item.id)", destination: WordpressSite.wordhord.pageURL(id: item.id))
            }
            
            Section(header: Text("Link")) {
                Link(item.link, destination: URL(string: item.link)!)
            }
            
            Section(header: Text("Slug")) {
                Text(item.slugCleaned)
            }
            
            if let content = item as? (any WordpressContent) {
                Section(header: Text("Date Posted")) {
                    Text(content.date_gmt, style: .date)
                }
                
                Section(header: Text("Date Modified")) {
                    Text(content.modified_gmt, style: .date)
                }
                
                Section(header: Text("Excerpt")) {
                    VStack(alignment: .leading, spacing: 0) {
                        if let attributedString = attributedString(from: content.excerptCleaned) {
                            Text(attributedString)
                        } else {
                            Text(content.excerptCleaned)
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
                
              Section(header: Text("Content")) {
                    VStack(alignment: .leading, spacing: 0) {
                        if let attributedString = attributedString(from: content.contentHtml) {
                            Text(attributedString)
                        } else {
                            Text(content.contentHtml)
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            if let post = item as? WordpressPost {
                Section(header: Text("Categories")) {
                    ForEach(post.categories, id: \.self) { id in
                        Text(String(id))
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(post.tags, id: \.self) { id in
                        Text(String(id))
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}

@available(iOS 15, *)
struct WordpressItemView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressItemView(WordpressPost.example)
        
        WordpressItemView(WordpressPage.example)
        
        WordpressItemView(WordpressCategory.example)
    }
}
