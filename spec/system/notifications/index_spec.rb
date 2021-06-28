require "rails_helper"

RSpec.describe "notifications/index", :disable_bullet, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }
  let(:case_contact) { create(:case_contact, creator: volunteer) }
  let(:casa_case) { case_contact.casa_case }

  before { casa_case.assigned_volunteers << volunteer }

  context "FollowupResolvedNotification" do
    let(:notification_message) { "#{volunteer.display_name} resolved a follow up. Click to see more." }
    let!(:followup) { create(:followup, creator: admin, case_contact: case_contact) }

    it "lists my notifications" do
      sign_in volunteer

      visit case_contacts_path
      click_button "Resolve"

      sign_in admin
      visit notifications_path

      expect(page).to have_text(notification_message)
      expect(page).to have_text("Followup resolved")
    end
  end

  context "FollowupNotification", js: true do
    let(:note) { "Lorem ipsum dolor sit amet." }

    let(:notification_message_heading) { "#{admin.display_name} has flagged a Case Contact that needs follow up." }
    let(:notification_message_more_info) { "Click to see more." }

    let(:inline_notification_message) { "#{notification_message_heading} #{notification_message_more_info}" }

    before do
      sign_in admin
      visit casa_case_path(casa_case)
    end

    context "when followup has a note" do
      before do
        click_button "Follow up"
        find(".swal2-textarea").set(note)

        click_button "Confirm"
      end

      it "lists followup notifications, showing their note" do
        # Wait until page reloads
        expect(page).to have_content "Resolve"

        sign_in volunteer
        visit notifications_path

        expect(page).to have_text(notification_message_heading)
        expect(page).to have_text(note)
        expect(page).to have_text(notification_message_more_info)
        expect(page).to have_text("New followup")
      end
    end

    context "when followup doesn't have a note" do
      before do
        click_button "Follow up"
        click_button "Confirm"
      end

      it "lists followup notifications, showing the information in a single line when there are no notes" do
        # Wait until page reloads
        expect(page).to have_content "Resolve"

        sign_in volunteer
        visit notifications_path

        expect(page).to have_text(inline_notification_message)
        expect(page).to have_text("New followup")
      end
    end
  end
end
