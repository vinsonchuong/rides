require 'digest/md5'

class TripsController < ApplicationController
  before_filter :authenticate_person!

  # GET /trips
  def index
    unless params[:month].nil? || params[:year].nil?
      @trips = current_person.trips.select do |trip|
        trip.time.month == params[:month].to_i && trip.time.year == params[:year].to_i
      end
    else
      @trips = current_person.trips
    end
    @trips = @trips.sort {|x, y| x.time <=> y.time}.reverse

    @months_with_trips = current_person.trips.map {|trip| trip.time}.sort.reverse
      .map {|time| {:month => time.month, :year => time.year}}
      .uniq
  end

  # GET /trips/1
  def show
    @trip = Trip.find(params[:id])
  end

  # GET /trips/new
  def new
    @trip = current_person.organized_trips.build
  end

  # GET /trips/1/edit
  def edit
    @trip = current_person.organized_trips.find(params[:id])
  end

  # POST /trips
  def create
    @trip = current_person.organized_trips.build(params[:trip])
    @trip.participants << current_person

    if @trip.save
      redirect_to(@trip, :notice => 'Trip was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /trips/1
  def update
    @trip = Trip.find(params[:id])

    if @trip.update_attributes(params[:trip])
      redirect_to(@trip, :notice => 'Trip was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /trips/1
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy

    redirect_to(person_root_url)
  end

  # GET /trips/1/participants
  def participants
    @trip = Trip.find(params[:id])
    @participants = @trip.participants.sort_by {|participant| participant.name}
    @invitees = @trip.invitees.sort
    @invitation = Invitation.new
  end

  # DELETE /trips/1/participants
  def leave
    @trip = Trip.find(params[:id])
    @trip.participants.delete(current_person)

    redirect_to(person_root_url, :notice => "You are no longer participating in #{@trip.name}")
  end

  # POST /trips/1/invitations
  def invite
    @trip = Trip.find(params[:id])
    @invitation = @trip.invitations.build(params[:invitation])
    @invitation.token = Digest::MD5.hexdigest(params[:invitation][:email] + @trip.id.to_s)

    if @invitation.save
      redirect_to(participants_trip_url(@trip), :notice => "#{params[:invitation][:email]} has been invited.")
    else
      @participants = @trip.participants.sort_by {|participant| participant.name}
      @invitees = @trip.invitees.sort
      render :action => 'participants'
    end
  end
end
