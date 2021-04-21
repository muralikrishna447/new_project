require 'spec_helper'

describe Api::V0::EmbedPdfsController do
  include Docs::V0::EmbedPdfs::Api

  context 'authenticated user is admin role', :dox do
    before :each do
      @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
      @embed_pdf = Fabricate :embed_pdf, title: 'Title PDF', image_id: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}", pdf_id: 'http://foo/bar.pdf'
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
    end

    describe 'GET #show' do
      include Docs::V0::EmbedPdfs::Show
      # GET /api/v0/embed_pdfs/:slug
      it 'should get a embed pdf by slug' do
        get :show,  params: {id: @embed_pdf.slug}

        response.should be_success
        result = JSON.parse(response.body)
        result.delete('title').should == @embed_pdf.title
        result.delete('imageUrl').should == @embed_pdf.image_url
        result.delete('imageAlt').should == @embed_pdf.image_alt
        result.delete('imageLongdesc').should == @embed_pdf.image_longdesc
        result.delete('pdfUrl').should == @embed_pdf.pdf_id

        result.empty?.should == true
      end

      # GET /api/v0/embed_pdfs/:id
      it 'should get a embed pdf by id' do
        get :show, params: {id: @embed_pdf.id}

        response.should be_success
        result = JSON.parse(response.body)
        result.length.should eq(5)
      end

      # GET /api/v0/embed_pdfs/:id
      it 'should return 404 when embed pdf not found by id' do
        get :show,  params: {id: 9999}
        response.code.should == '404'
      end

      # GET /api/v0/embed_pdfs/:slug
      it 'should return 404 when embed pdf not found by slug' do
        get :show,  params: {id: 'not-a-slug'}
        response.code.should == '404'
      end
    end
  end

  context 'authenticated user is user role', :dox do
    before :each do
      @user = Fabricate :user, name: 'Normal User', email: 'user@chefsteps.com', role: 'user'
      @embed_pdf = Fabricate :embed_pdf, title: 'Title PDF', image_id: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}", pdf_id: 'http://foo/bar.pdf'
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    end

    describe 'GET #show' do
      include Docs::V0::EmbedPdfs::Show
      # GET /api/v0/embed_pdfs/:slug
      it 'should get a embed pdf by slug' do
        get :show,  params: {id: @embed_pdf.slug}
        response.should be_success
        response.code.should eq('200')
      end

      # GET /api/v0/embed_pdfs/:id
      it 'should get a embed pdf for id' do
        get :show,  params: {id: @embed_pdf.id}
        response.should be_success
        response.code.should eq('200')
      end
    end
  end
end
