//
//  AvatarPickerView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 10/04/2023.
//

import SwiftUI

fileprivate struct EmptyAvatarItemView: View {
  var selection: Binding<String?>

  @ViewBuilder var background: some View {
    if selection.wrappedValue == nil {
      Circle()
        .fill(.blue)
        .frame(width: 68, height: 68)
    }
  }

  var body: some View {
    Circle()
      .fill(Color(nsColor: .controlBackgroundColor))
      .frame(width: 62, height: 62)
      .overlay(
        Text("None")
      )
      .onTapGesture {
        selection.wrappedValue = nil
      }
      .background(
        background
      )
  }
}

fileprivate struct AvatarItemView: View {
  let resourceName: String
  var selection: Binding<String?>

  @ViewBuilder var background: some View {
    if selection.wrappedValue == resourceName {
      Circle()
        .fill(.blue)
        .frame(width: 68, height: 68)
        // Resources are a bit off-center oops
        .padding(.top, 2)
    }
  }

  var body: some View {
    Image(resourceName)
      .resizable()
      .scaledToFit()
      .frame(width: 64, height: 64)
      .onTapGesture {
        selection.wrappedValue = resourceName
      }
      .background(
        background
      )
  }
}

struct AvatarPickerView: View {
  var selectedAvatar: Binding<String?>

  var body: some View {
    Grid {
      GridRow {
        EmptyAvatarItemView(selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-1", selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-2", selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-3", selection: selectedAvatar)
      }
      GridRow {
        AvatarItemView(resourceName: "avatar-4", selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-6", selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-7", selection: selectedAvatar)
        AvatarItemView(resourceName: "avatar-8", selection: selectedAvatar)
      }
    }
      .padding()
  }
}
