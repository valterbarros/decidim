# frozen_string_literal: true

require "spec_helper"

describe "Manage participatory processes", type: :feature do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:participatory_process) { create(:process, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  it "creates a new participatory_process" do
    find(".actions .new").click

    within ".new_participatory_process" do
      fill_in :participatory_process_title_en, with: "My participatory process"
      fill_in :participatory_process_title_es, with: "Mi proceso participativo"
      fill_in :participatory_process_title_ca, with: "El meu procés participatiu"
      fill_in :participatory_process_subtitle_en, with: "Subtitle"
      fill_in :participatory_process_subtitle_es, with: "Subtítulo"
      fill_in :participatory_process_subtitle_ca, with: "Subtítol"
      fill_in :participatory_process_slug, with: "slug"
      fill_in :participatory_process_hashtag, with: "#hashtag"
      fill_in :participatory_process_short_description_en, with: "Short description"
      fill_in :participatory_process_short_description_es, with: "Descripción corta"
      fill_in :participatory_process_short_description_ca, with: "Descripció curta"
      fill_in :participatory_process_description_en, with: "A longer description"
      fill_in :participatory_process_description_es, with: "Descripción más larga"
      fill_in :participatory_process_description_ca, with: "Descripció més llarga"

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My participatory process")
    end
  end

  it "updates an participatory_process" do
    within find("tr", text: participatory_process.title["en"]) do
      click_link "Edit"
    end

    within ".edit_participatory_process" do
      fill_in :participatory_process_title_en, with: "My new title"
      fill_in :participatory_process_title_es, with: "Mi nuevo título"
      fill_in :participatory_process_title_ca, with: "El meu nou títol"

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "deleting a participatory process" do
    let!(:participatory_process2) { create(:process, organization: organization) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "deletes a participatory_process" do
      within find("tr", text: participatory_process2.title["en"]) do
        click_link "Destroy"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(participatory_process2.title)
      end
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_participatory_process) { create(:process) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "doesn't let the admin manage processes form other organizations" do
      within "table" do
        expect(page).to_not have_content(external_participatory_process.title)
      end
    end
  end

  context "when the user is not authorized to perform some actions" do
    let(:policy_double) { double edit?: policy_edit }
    let(:policy_edit) { true }

    before do
      allow(Decidim::Admin::ParticipatoryProcessPolicy)
        .to receive(:new)
        .and_return(policy_double)
    end

    context "it can't edit a record" do
      let(:policy_edit) { false }

      context 'when the user tries to manually access to the edition page' do
        it "is redirected to the root path" do
          visit decidim_admin.edit_participatory_process_path(participatory_process)
          expect(page).to have_content("You are not authorized to perform this action")
          expect(current_path).to eq decidim_admin.root_path
        end
      end
    end
  end
end