import SwiftUI

struct NotesView: View {
    @StateObject private var notesManager = NotesManager()
    @State private var newNoteText = ""
    @State private var editingNote: Note? = nil
    @State private var selectedNote: Note? = nil
    @State private var selectedNoteForDetail: Note? = nil
    @State private var showDeleteAlert = false
    @State private var noteToDelete: Note? = nil
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var tabSelection: TabSelection
    
    var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    // 展开态：左右分栏
                    HStack(spacing: 0) {
                        // 左侧：原有布局
                        notesListSection
                            .frame(maxWidth: 350)
                        
                        Divider()
                        
                        // 右侧：详情区域
                        detailSection
                    }
                } else {
                    // 折叠态：原有单列布局
                    notesListSection
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedNote) { note in
                NoteDetailView(
                    note: note,
                    onEdit: {
                        selectedNote = nil
                        startEditing(note)
                    },
                    onDelete: {
                        selectedNote = nil
                        noteToDelete = note
                        showDeleteAlert = true
                    }
                )
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {
                    noteToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let note = noteToDelete {
                        notesManager.deleteNote(note)
                    }
                    noteToDelete = nil
                }
            } message: {
                Text("删除后无法恢复，确定要删除这条笔记吗？")
            }
        }
    }
    
    // MARK: - 左侧笔记列表区域
    private var notesListSection: some View {
        VStack(spacing: 0) {
            // 头部标题
            Text("笔记")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .italic()
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple, .pink.opacity(0.9)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .accessibilityIdentifier("notes_title")
            
            // 输入区域
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    TextField(editingNote == nil ? "快来写点什么吧..." : "编辑笔记...", text: $newNoteText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .accessibilityIdentifier("notes_input_field")
                    
                    Button(action: addOrUpdateNote) {
                        Image(systemName: editingNote == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .purple)
                    }
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("notes_add_update_button")
                }
                
                if editingNote != nil {
                    HStack {
                        Spacer()
                        Button("取消编辑") {
                            cancelEditing()
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.purple)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 内容区域
            if notesManager.notes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 50))
                        .foregroundColor(.purple.opacity(0.5))
                    Text("暂无笔记")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("notes_empty_label")
                    Text("添加笔记来记录你的想法")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notesManager.notes) { note in
                            NoteCard(
                                note: note,
                                onTap: {
                                    if sizeClass == .regular {
                                        selectedNoteForDetail = note
                                    } else {
                                        selectedNote = note
                                    }
                                },
                                onEdit: {
                                    startEditing(note)
                                },
                                onDelete: {
                                    noteToDelete = note
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - 右侧详情区域
    private var detailSection: some View {
        Group {
            if let note = selectedNoteForDetail {
                NoteDetailContent(
                    note: note,
                    onEdit: {
                        startEditing(note)
                    },
                    onDelete: {
                        noteToDelete = note
                        showDeleteAlert = true
                    }
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 50))
                        .foregroundColor(.purple.opacity(0.5))
                    Text("选择一条笔记")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("从左侧列表点击笔记查看详情")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func startEditing(_ note: Note) {
        editingNote = note
        newNoteText = note.text
    }
    
    private func cancelEditing() {
        editingNote = nil
        newNoteText = ""
    }
    
    private func addOrUpdateNote() {
        let trimmedText = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        if let note = editingNote {
            notesManager.updateNote(note, newText: trimmedText)
            editingNote = nil
        } else {
            notesManager.addNote(text: trimmedText)
        }
        newNoteText = ""
    }
}

// MARK: - 笔记卡片组件
struct NoteCard: View {
    let note: Note
    var onTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 笔记内容
            Text(note.text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // 底部信息
            HStack {
                // 时间戳
                Text(formatDate(note.timestamp))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                onTap()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 笔记详情内容（用于分栏布局）
struct NoteDetailContent: View {
    let note: Note
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 时间戳
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(formatFullDate(note.timestamp))
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // 笔记内容
            ScrollView {
                Text(note.text)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // 底部操作按钮
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("编辑")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
                    .padding()
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("删除")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
                    .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - 笔记详情视图
struct NoteDetailView: View {
    let note: Note
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // 时间戳
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text(formatFullDate(note.timestamp))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 笔记内容
                ScrollView {
                    Text(note.text)
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // 底部操作按钮
                HStack(spacing: 16) {
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("编辑")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
                        .padding()
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    
                    Button(action: onDelete) {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                        .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView().environmentObject(TabSelection())
    }
}
