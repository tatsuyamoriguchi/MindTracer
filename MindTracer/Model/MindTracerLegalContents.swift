//
//  MindTracerLegalContents.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import Foundation

//struct MindTracerLegalContents {
//    let legal = "Mind Tracer is a wellness and self-reflection application designed to help users track and better understand their mental and emotional patterns. It does not provide medical, mental health, diagnostic, or treatment services. \n\nThe content, insights, and visualizations provided by Mind Tracer are for informational purposes only and should not be considered medical or professional advice. Always seek the guidance of a qualified healthcare professional with any questions or concerns regarding your health. \n\nThe developer makes no guarantees regarding accuracy or outcomes and is not responsible for decisions made based on information provided by the app."
//    let copyright = "© 2026 Tatsuya Moriguchi\n\nAll rights reserved. \n\nMind Tracer and its associated content, design, and software are the intellectual property of Tatsuya Moriguchi. \n\nUnauthorized copying, distribution, or use of this application or its content is strictly prohibited."
//    let contact = "Support at ModalFlo Mobile Solutions\n\nPhone: +1 949-345-0034"
//    let webSite = "https://modalflo.com/mindtracer/support.html"
//    let email = "Email: support@modalflo.com"
//    let source1 = "American Psychological Association — Emotion & Emotional Regulation"
//    let source1Url = "https://dictionary.apa.org/emotion-regulation"
//    let source2 = "National Institute of Mental Health — Mental Health Basics"
//    let source2Url = "https://www.nimh.nih.gov/health/topics"
//    let source3 = "World Health Organization — Mental Well-being"
//    let source3Url = "https://www.un.org/en/global-issues/mental-health"
//}

enum MindTracerLegalContents: CaseIterable, Identifiable {
    case legal
    case copyright
    case contact
    case website
    case email
    case sourceAPA
    case sourceNIMH
    case sourceWHO
    case citation

    var id: Self { self }

    var title: String {
        switch self {
        case .legal: return "Legal Disclaimer"
        case .copyright: return "Copyright"
        case .contact: return "Support Contact"
        case .website: return "Mind Tracer Support"
        case .email: return "Support Email"
        case .sourceAPA: return "American Psychological Association"
        case .sourceNIMH: return "National Institute of Mental Health"
        case .sourceWHO: return "World Health Organization"
        case .citation: return "Citation"
        }
    }

    var content: String {
        switch self {
        case .legal:
            return """
            Mind Tracer is a wellness and self-reflection application designed to help users track and better understand their mental and emotional patterns. It does not provide medical, mental health, diagnostic, or treatment services.

            The content, insights, and visualizations provided by Mind Tracer are for informational purposes only and should not be considered medical or professional advice. Always seek the guidance of a qualified healthcare professional with any questions or concerns regarding your health.

            The developer makes no guarantees regarding accuracy or outcomes and is not responsible for decisions made based on information provided by the app.
            """
        case .copyright:
            return "© 2026 Tatsuya Moriguchi (ModalFlo Mobile Solutions),  All rights reserved."
        case .contact:
            return "Support at ModalFlo Mobile Solutions\nPhone: +1 949-345-0034"
        case .website:
            return "https://modalflo.com/mindtracer/support.html"
        case .email:
            return "support@modalflo.com"
        case .sourceAPA:
            return "Emotion & Emotional Regulation"
        case .sourceNIMH:
            return "Mental Health Basics"
        case .sourceWHO:
            return "Mental Well-being"
        case .citation:
            return "The following publicly available resources inform the general wellness concepts referenced in this app."
        }
    }

    var url: URL? {
        switch self {
        case .sourceAPA:
            return URL(string: "https://dictionary.apa.org/emotion-regulation")
        case .sourceNIMH:
            return URL(string: "https://www.nimh.nih.gov/health/topics")
        case .sourceWHO:
            return URL(string: "https://www.un.org/en/global-issues/mental-health")
        case .website:
            return URL(string: "https://modalflo.com/mindtracer/support.html")
        default:
            return nil
        }
    }
}

