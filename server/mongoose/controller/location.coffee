env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
Promise = require '../../../promise.coffee'

error = (res, msg) ->
	res.json 500, error: msg

class Location

	@list: (req, res) ->
		model.Location.find().sort({name: 'asc'}).exec (err, location) ->
			if err or location == null
				return error res, if err then err else "location not found"
			res.json location
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		location = new model.Location data
		location.save (err) =>
			if err
				return error res, err
			res.json location			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Location.findById(id).exec (err, location) ->
			if err or location == null
				return error res, if err then err else "location not found"
			res.json location			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Location.findOne {_id: id, __v: req.body.__v}, (err, location) ->
			if err or location == null
				return error res, if err then err else "location not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				location[key] = value
			location.updatedBy = req.user
			location.save (err) ->
				if err
					error res, err
				else res.json location				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Location.findOne {_id: id}, (err, location) ->		
			if err or location == null
				return error res, if err then err else "location not found"
			
			location.remove (err, location) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Location: 		Location