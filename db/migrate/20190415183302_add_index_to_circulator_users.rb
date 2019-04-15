class AddIndexToCirculatorUsers < ActiveRecord::Migration
  def change
    add_index(:circulator_users, :circulator_id)
  end
end



-- Name: index_circulator_users_on_circulator_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
  --

  CREATE INDEX index_circulator_users_on_circulator_id ON public.circulator_users USING btree (circulator_id);


--
-- Name: index_circulator_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
  --

  CREATE INDEX index_circulator_users_on_deleted_at ON public.circulator_users USING btree (deleted_at);



INSERT INTO schema_migrations (version) VALUES ('20190415183302');
